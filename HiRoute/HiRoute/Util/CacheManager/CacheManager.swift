//
//  CacheManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
import Foundation
import UIKit
import CryptoKit


/*
 통합 메모리 관리: 전체 앱 캐시를 한곳에서
 일관된 정책: TTL, LRU 등 통일된 정책
 타입 안전성: Generic으로 타입 보장
 성능 모니터링: 캐시 히트율 추적 가능
 */

class CacheManager: NSObject {
    static let shared = CacheManager()
    
    private let cache = NSCache<NSString, CacheWrapper>()
    private let queue = DispatchQueue(label: "CacheManager", qos: .utility)
    private var accessTimes: [String: Date] = [:]
    
    // ✅ 캐시 통계 추적
    private var totalRequests: Int = 0
    private var totalHits: Int = 0
    private var currentCacheSize: Int = 0
    
    // ✅ 앱 전체 크기 제한 (400MB 중 캐시는 50MB로 제한)
    private let maxCacheSize: Int = 50 * 1024 * 1024 // 50MB
    private let maxItemCount: Int = 1000
    
    enum CacheKey {
        case schedule(String)
        case place(String)
        case review(String)
        case scheduleList(page: Int, size: Int)
        case placeList(page: Int, size: Int)
        case userProfile(String)
        case image(String)
        
        var stringValue: String {
            switch self {
            case .schedule(let uid): return "schedule_\(uid)"
            case .place(let uid): return "place_\(uid)"
            case .review(let uid): return "review_\(uid)"
            case .scheduleList(let page, let size): return "schedule_list_\(page)_\(size)"
            case .placeList(let page, let size): return "place_list_\(page)_\(size)"
            case .userProfile(let uid): return "user_\(uid)"
            case .image(let url): return "image_\(url.hash)"
            }
        }
        
        var estimatedCost: Int {
            switch self {
            case .schedule, .place, .review: return 2048 // 2KB
            case .scheduleList, .placeList: return 20480 // 20KB
            case .userProfile: return 1024 // 1KB
            case .image: return 102400 // 100KB
            }
        }
        
        var priority: CachePriority {
            switch self {
            case .schedule, .place: return .high
            case .scheduleList, .placeList: return .medium
            case .userProfile: return .low
            case .review, .image: return .low
            }
        }
    }
    
    private override init() {
        super.init()
        setupCache()
        setupMemoryWarning()
        setupBackgroundCleanup()
    }
    
    private func setupCache() {
        cache.countLimit = maxItemCount
        cache.totalCostLimit = maxCacheSize
        cache.delegate = self
    }
    
    private func setupMemoryWarning() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryPressure()
        }
    }
    
    private func setupBackgroundCleanup() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.performMaintenanceCleanup()
        }
    }
    
    // MARK: - ✅ 데이터 무결성 기반 CRUD
    
    /// 안전한 캐시 저장 (데이터 검증 포함)
    func safeSet<T: CacheableModel>(_ object: T, forKey key: CacheKey) -> CacheResult {
        return queue.sync { [weak self] in
            guard let self = self else { return .failed(.systemError) }
            
            // 크기 제한 확인
            if !self.hasSpaceForNewItem(cost: key.estimatedCost) {
                self.makeSpaceForNewItem(priority: key.priority, cost: key.estimatedCost)
            }
            
            let keyString = key.stringValue
            let wrapper = CacheWrapper(data: object, priority: key.priority, cost: key.estimatedCost)
            
            // 기존 데이터와 비교
            if let existingWrapper = self.cache.object(forKey: keyString as NSString) {
                let result = self.validateAndUpdate(new: wrapper, existing: existingWrapper, key: keyString)
                return result
            }
            
            // 새로운 데이터 저장
            self.cache.setObject(wrapper, forKey: keyString as NSString, cost: key.estimatedCost)
            self.accessTimes[keyString] = Date()
            self.currentCacheSize += key.estimatedCost
            
            print("💾 캐시 저장: \(keyString)")
            return .success(.created)
        }
    }
    
    /// 검증된 캐시 조회
    func safeGet<T: CacheableModel>(_ type: T.Type, forKey key: CacheKey) -> T? {
        return queue.sync { [weak self] in
            guard let self = self else { return nil }
            
            self.totalRequests += 1
            let keyString = key.stringValue
            
            guard let wrapper = self.cache.object(forKey: keyString as NSString),
                  let object = wrapper.data as? T else {
                print("❌ 캐시 미스: \(keyString)")
                return nil
            }
            
            // 데이터 무결성 검증
            if !self.validateCacheIntegrity(wrapper: wrapper) {
                self.cache.removeObject(forKey: keyString as NSString)
                self.accessTimes.removeValue(forKey: keyString)
                print("🚨 손상된 캐시 데이터 제거: \(keyString)")
                return nil
            }
            
            // 만료 확인
            if self.isExpired(wrapper: wrapper) {
                self.cache.removeObject(forKey: keyString as NSString)
                self.accessTimes.removeValue(forKey: keyString)
                print("⏰ 만료된 캐시 데이터 제거: \(keyString)")
                return nil
            }
            
            self.totalHits += 1
            self.accessTimes[keyString] = Date()
            print("✅ 캐시 히트: \(keyString)")
            return object
        }
    }
    
    /// 조건부 업데이트
    func updateIf<T: CacheableModel>(_ object: T, forKey key: CacheKey,
                                     condition: @escaping (T?) -> Bool) -> CacheResult {
        return queue.sync { [weak self] in
            guard let self = self else { return .failed(.systemError) }
            
            let keyString = key.stringValue
            let existingWrapper = self.cache.object(forKey: keyString as NSString)
            let existingData = existingWrapper?.data as? T
            
            if condition(existingData) {
                return self.safeSet(object, forKey: key)
            }
            
            return .failed(.conditionNotMet)
        }
    }
    
    func remove(forKey key: CacheKey) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let keyString = key.stringValue
            if let wrapper = self.cache.object(forKey: keyString as NSString) {
                self.currentCacheSize -= wrapper.cost
            }
            
            self.cache.removeObject(forKey: keyString as NSString)
            self.accessTimes.removeValue(forKey: keyString)
            print("🗑️ 캐시 제거: \(keyString)")
        }
    }
    
    func removeAll(matching pattern: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let keysToRemove = self.accessTimes.keys.filter { $0.contains(pattern) }
            
            for key in keysToRemove {
                if let wrapper = self.cache.object(forKey: key as NSString) {
                    self.currentCacheSize -= wrapper.cost
                }
                self.cache.removeObject(forKey: key as NSString)
                self.accessTimes.removeValue(forKey: key)
            }
            
            print("🧹 패턴 매칭 캐시 제거: \(pattern), \(keysToRemove.count)개")
        }
    }
    
    func clearAll() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let count = self.accessTimes.count
            self.cache.removeAllObjects()
            self.accessTimes.removeAll()
            self.currentCacheSize = 0
            self.totalRequests = 0
            self.totalHits = 0
            
            print("🧹 전체 캐시 삭제: \(count)개 항목")
        }
    }
    
    
    // MARK: - ✅ 데이터 검증 및 최적화 로직
    
    private func validateAndUpdate(new: CacheWrapper, existing: CacheWrapper, key: String) -> CacheResult {
        guard let newData = new.data as? CacheableModel,
              let existingData = existing.data as? CacheableModel else {
            return .failed(.dataCorruption)
        }
        
        // 해시 기반 데이터 비교
        if newData.contentHash == existingData.contentHash {
            accessTimes[key] = Date()
            return .success(.noChange)
        }
        
        // 버전 기반 검증
        if newData.version < existingData.version {
            return .failed(.staleVersion)
        }
        
        if newData.version == existingData.version && newData.lastModified <= existingData.lastModified {
            return .failed(.staleData)
        }
        
        // 업데이트 수행
        cache.setObject(new, forKey: key as NSString, cost: new.cost)
        accessTimes[key] = Date()
        
        return .success(.updated)
    }
    
    private func validateCacheIntegrity(wrapper: CacheWrapper) -> Bool {
        guard let data = wrapper.data as? CacheableModel else { return false }
        
        // 해시 검증
        let computedHash = data.contentHash
        if computedHash != wrapper.originalHash {
            return false
        }
        
        return true
    }
    
    private func isExpired(wrapper: CacheWrapper) -> Bool {
        let now = Date()
        return now.timeIntervalSince(wrapper.createdAt) > 3600 // 1시간
    }
    
    // ✅ 메모리 최적화
    private func hasSpaceForNewItem(cost: Int) -> Bool {
        return currentCacheSize + cost <= maxCacheSize && accessTimes.count < maxItemCount
    }
    
    private func makeSpaceForNewItem(priority: CachePriority, cost: Int) {
        // 우선순위 기반 정리
        let sortedItems = accessTimes.sorted { $0.value < $1.value }
        var freedSpace = 0
        
        for (key, _) in sortedItems {
            if let wrapper = cache.object(forKey: key as NSString) {
                // 낮은 우선순위부터 제거
                if wrapper.priority.rawValue < priority.rawValue || freedSpace < cost {
                    currentCacheSize -= wrapper.cost
                    freedSpace += wrapper.cost
                    
                    cache.removeObject(forKey: key as NSString)
                    accessTimes.removeValue(forKey: key)
                    
                    if freedSpace >= cost && currentCacheSize + cost <= maxCacheSize {
                        break
                    }
                }
            }
        }
        
        print("🧹 공간 확보: \(freedSpace)bytes")
    }
    
    private func performMaintenanceCleanup() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let expireTime = Date().addingTimeInterval(-3600)
            let expiredKeys = self.accessTimes.compactMap { (key, date) in
                date < expireTime ? key : nil
            }
            
            for key in expiredKeys {
                if let wrapper = self.cache.object(forKey: key as NSString) {
                    self.currentCacheSize -= wrapper.cost
                }
                self.cache.removeObject(forKey: key as NSString)
                self.accessTimes.removeValue(forKey: key)
            }
            
            // 크기가 80% 이상이면 20% 정리
            if Double(self.currentCacheSize) / Double(self.maxCacheSize) > 0.8 {
                self.cleanupByLRU(targetReduction: 0.2)
            }
            
            print("🧹 유지보수 정리 완료: \(expiredKeys.count)개 만료 항목 제거")
        }
    }
    
    private func cleanupByLRU(targetReduction: Double) {
        let targetSize = Int(Double(maxCacheSize) * (1.0 - targetReduction))
        let sortedKeys = accessTimes.sorted { $0.value < $1.value }
        
        for (key, _) in sortedKeys {
            if currentCacheSize <= targetSize { break }
            
            if let wrapper = cache.object(forKey: key as NSString) {
                currentCacheSize -= wrapper.cost
                cache.removeObject(forKey: key as NSString)
                accessTimes.removeValue(forKey: key)
            }
        }
    }
    
    func handleMemoryPressure() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 긴급 상황: 50% 정리
            self.cleanupByLRU(targetReduction: 0.5)
            print("⚠️ 메모리 압박 대응: 캐시 50% 정리")
        }
    }
    
    private func calculateHitRate() -> Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(totalHits) / Double(totalRequests) * 100.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        clearAll()
        print("✅ CacheManager deinit")
    }
}

// MARK: - NSCacheDelegate
extension CacheManager: NSCacheDelegate {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: AnyObject) {
        if let wrapper = obj as? CacheWrapper {
            currentCacheSize -= wrapper.cost
        }
    }
}
