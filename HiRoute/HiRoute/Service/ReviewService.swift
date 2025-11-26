//
//  ReviewService.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Combine
import Foundation

class ReviewService {
    private let reviewProtocol: ReviewProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(reviewProtocol: ReviewProtocol) {
        self.reviewProtocol = reviewProtocol
    }
    
    // Repository 메서드들
    func createReview(placeUID: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        reviewProtocol.createReview(placeUID: placeUID, reviewModel: reviewModel)
            .handleEvents(receiveOutput: { [weak self] review in
                print("📝 Review created: \(reviewModel.reviewUID)")
            })
            .eraseToAnyPublisher()
    }
    
    func updateReview(reviewUID: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        reviewProtocol.updateReview(reviewUID: reviewUID, reviewModel: reviewModel)
            .handleEvents(receiveOutput: { [weak self] _ in
                print("📝 Review created: \(reviewModel.reviewUID)")
            })
            .eraseToAnyPublisher()
    }
    
    func deleteReview(reviewUID: String) -> AnyPublisher<Void, Error> {
        reviewProtocol.deleteReview(reviewUID: reviewUID)
            .handleEvents(receiveOutput: { [weak self] _ in
                print("📝 Review created: \(reviewUID)")
            })
            .eraseToAnyPublisher()
    }
    
    func readReviewList(placeUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        reviewProtocol.readReviewList(placeUID: placeUID, page: page, itemsPerPage: itemsPerPage)
    }
    
    func readMyReviewList(userUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        reviewProtocol.readMyReviewList(userUID: userUID, page: page, itemsPerPage: itemsPerPage)
    }
    
    func toggleReviewUseful(reviewUID: String, userUID: String) -> AnyPublisher<Bool, Error> {
        reviewProtocol.toggleReviewUseful(reviewUID: reviewUID, userUID: userUID)
    }
    
    func reportReview(reviewUID: String, reporterUID: String, reportType: String, reportReason: String) -> AnyPublisher<Void, Error> {
        reviewProtocol.reportReview(reviewUID: reviewUID, reporterUID: reporterUID, reportType: reportType, reportReason: reportReason)
    }
    
    // 🚀 Service만의 추가 기능들
    func getReviewsWithSorting(placeUID: String, sortBy: ReviewListFilterType, page: Int = 1, itemsPerPage: Int = 10) -> AnyPublisher<[ReviewModel], Error> {
        readReviewList(placeUID: placeUID, page: page, itemsPerPage: itemsPerPage)
            .map { [weak self] reviews in
                self?.sortReviews(reviews, by: sortBy) ?? reviews
            }
            .eraseToAnyPublisher()
    }
    
    private func sortReviews(_ reviews: [ReviewModel], by sortType: ReviewListFilterType) -> [ReviewModel] {
        switch sortType {
        case .new:
            return reviews.sorted { $0.visitDate > $1.visitDate }
        case .recommend:
            return reviews.sorted { $0.visitDate < $1.visitDate }
        case .manyStar:
            return reviews.sorted { $0.usefulList.count > $1.usefulList.count }
        case .littleStar:
            return reviews.sorted { $0.usefulList.count < $1.usefulList.count }
        }
    }
}

