//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine
import Foundation

class ScheduleRepository: ScheduleProtocol {
    
    // 메모리 캐시 - 최대 100개 항목만 유지
    private var cache = NSCache<NSString, NSArray>()
    private let cacheQueue = DispatchQueue(label: "com.schedule.cache", qos: .utility)
    
    init() {
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func createSchedule(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                // 실제 서버 통신 로직
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // 캐시 무효화
                    self.invalidateCache()
                    promise(.success(scheduleModel))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readSchedule(scheduleModelUID: String) -> AnyPublisher<ScheduleModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                // 캐시에서 먼저 찾기
                if let cachedSchedule = self.findInCache(uid: scheduleModelUID) {
                    promise(.success(cachedSchedule))
                    return
                }
                
                // 서버에서 가져오기
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let schedule = DummyPack.sampleSchedules.first(where: { $0.uid == scheduleModelUID }) {
                        promise(.success(schedule))
                    } else {
                        promise(.failure(ScheduleError.notFound))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readScheduleList(page: Int, itemsPerPage: Int) -> AnyPublisher<[ScheduleModel], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            let cacheKey = "page_\(page)_\(itemsPerPage)" as NSString
            
            // 캐시에서 먼저 확인
            self.cacheQueue.async {
                if let cachedData = self.cache.object(forKey: cacheKey) as? [ScheduleModel] {
                    DispatchQueue.main.async {
                        promise(.success(cachedData))
                    }
                    return
                }
                
                // 서버에서 가져오기
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let allSchedules = DummyPack.sampleSchedules
                        let startIndex = (page - 1) * itemsPerPage
                        let endIndex = min(startIndex + itemsPerPage, allSchedules.count)
                        
                        guard startIndex < allSchedules.count else {
                            promise(.success([]))
                            return
                        }
                        
                        let pageData = Array(allSchedules[startIndex..<endIndex])
                        
                        // 캐시에 저장 (백그라운드)
                        self.cacheQueue.async {
                            let nsArray = pageData as NSArray
                            self.cache.setObject(nsArray, forKey: cacheKey, cost: pageData.count)
                        }
                        
                        promise(.success(pageData))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateSchedule(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                // 실제 서버 업데이트 로직
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    // 캐시 무효화
                    self.invalidateCache()
                    promise(.success(scheduleModel))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteSchedule(scheduleModelUID: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                // 실제 서버 삭제 로직
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // 캐시 무효화
                    self.invalidateCache()
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func findInCache(uid: String) -> ScheduleModel? {
        // 모든 캐시된 페이지에서 해당 UID 찾기
        var result: ScheduleModel?
        let semaphore = DispatchSemaphore(value: 0)
        
        cacheQueue.async {
            // 캐시된 모든 데이터 순회 (실제로는 더 효율적인 방법 필요)
            // 여기서는 간소화
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    private func invalidateCache() {
        cacheQueue.async {
            self.cache.removeAllObjects()
        }
    }
}
