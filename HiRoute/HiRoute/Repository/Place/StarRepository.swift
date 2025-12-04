//
//  StarImplementation.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Foundation
import Combine

class StarRepository: StarProtocol {
    
    static let shared = StarRepository()
    
    // ✅ 캐시 관련 추가 (기존 코드는 그대로)
    private var cache = NSCache<NSString, AnyObject>()
    private let cacheQueue = DispatchQueue(label: "com.star.cache", qos: .utility)
    
    private init() {
        setupCache()  // ✅ 추가
    }
    
    // ✅ 캐시 설정 추가
    private func setupCache() {
        cache.countLimit = 50
        cache.totalCostLimit = 5 * 1024 * 1024  // 5MB
    }
    
    // ✅ 캐시 정리 메소드 추가
    func clearCache() {
        cacheQueue.async { [weak self] in
            self?.cache.removeAllObjects()
        }
    }
    
    func optimizeCache() {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            let oldLimit = self.cache.totalCostLimit
            self.cache.totalCostLimit = oldLimit / 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.cache.totalCostLimit = oldLimit
            }
        }
    }
    

    func createRate(placeUID: String, userUID: String, star: Int) -> AnyPublisher<StarModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    let starModel = StarModel(userUID: userUID, star: star)
                    promise(.success(starModel))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func removeRate(placeUID: String, userUID: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    func readAverageRate(placeUID: String) -> AnyPublisher<Double, Error> {
        Future { promise in
            DispatchQueue.global().async {
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    let stars = place.stars
                    if stars.isEmpty {
                        promise(.success(0.0))
                    } else {
                        let total = stars.map { $0.star }.reduce(0, +)
                        let average = Double(total) / Double(stars.count)
                        promise(.success(average))
                    }
                } else {
                    promise(.success(0.0))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func readMyRateList(placeUID: String, userUID: String) -> AnyPublisher<Int?, Error> {
        Future { promise in
            DispatchQueue.global().async {
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    let userStar = place.stars.first { $0.userUID == userUID }
                    promise(.success(userStar?.star))
                } else {
                    promise(.success(nil))
                }
            }
        }.eraseToAnyPublisher()
    }
}
