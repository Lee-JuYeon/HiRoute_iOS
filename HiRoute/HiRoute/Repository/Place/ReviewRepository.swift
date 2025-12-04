//
//  ServiceContainer.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Foundation
import Combine

class ReviewRepository: ReviewProtocol {
    static let shared = ReviewRepository()

    // 메모리 캐시 - 최대 100개 항목만 유지
    private var cache = NSCache<NSString, AnyObject>()
    private let cacheQueue = DispatchQueue(label: "com.review.cache", qos: .utility)
    private init() {
        setupCache()
    }
    
    // ✅ 캐시 설정 추가
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
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
    
    func createReview(placeUID: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    promise(.success(reviewModel))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateReview(reviewUID: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    promise(.success(reviewModel))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteReview(reviewUID: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    func readReviewList(placeUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    let reviews = place.reviews
                    
                    let startIndex = (page - 1) * itemsPerPage
                    let endIndex = min(startIndex + itemsPerPage, reviews.count)
                    
                    guard startIndex < reviews.count else {
                        promise(.success([]))
                        return
                    }
                    
                    let pageData = Array(reviews[startIndex..<endIndex])
                    promise(.success(pageData))
                } else {
                    promise(.success([]))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func readMyReviewList(userUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) {
                var allReviews: [ReviewModel] = []
                
                for place in DummyPack.samplePlaces {
                    let userReviews = place.reviews.filter { $0.userUID == userUID }
                    allReviews.append(contentsOf: userReviews)
                }
                
                let startIndex = (page - 1) * itemsPerPage
                let endIndex = min(startIndex + itemsPerPage, allReviews.count)
                
                guard startIndex < allReviews.count else {
                    promise(.success([]))
                    return
                }
                
                let pageData = Array(allReviews[startIndex..<endIndex])
                promise(.success(pageData))
            }
        }.eraseToAnyPublisher()
    }
    
    func toggleReviewUseful(reviewUID: String, userUID: String) -> AnyPublisher<Bool, Error> {
        Future { promise in
            DispatchQueue.global().async {
                let isUseful = Bool.random()
                promise(.success(isUseful))
            }
        }.eraseToAnyPublisher()
    }
    
    func reportReview(reviewUID: String, reporterUID: String, reportType: String, reportReason: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                print("🚨 Review reported: \(reviewUID) - \(reportType)")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}
