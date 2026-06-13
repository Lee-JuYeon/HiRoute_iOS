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
    func createReview(placeUid: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        reviewProtocol.createReview(placeUid: placeUid, reviewModel: reviewModel)
            .handleEvents(receiveOutput: { _ in
                print("📝 Review created: \(reviewModel.reviewUid)")
            })
            .eraseToAnyPublisher()
    }

    func updateReview(reviewUid: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        reviewProtocol.updateReview(reviewUid: reviewUid, reviewModel: reviewModel)
            .handleEvents(receiveOutput: { _ in
                print("📝 Review updated: \(reviewModel.reviewUid)")
            })
            .eraseToAnyPublisher()
    }

    func deleteReview(reviewUid: String) -> AnyPublisher<Void, Error> {
        reviewProtocol.deleteReview(reviewUid: reviewUid)
            .handleEvents(receiveOutput: { _ in
                print("📝 Review deleted: \(reviewUid)")
            })
            .eraseToAnyPublisher()
    }

    func readReviewList(placeUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        reviewProtocol.readReviewList(placeUid: placeUid, page: page, itemsPerPage: itemsPerPage)
    }

    func readMyReviewList(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        reviewProtocol.readMyReviewList(userUid: userUid, page: page, itemsPerPage: itemsPerPage)
    }

    func readMyUsefulReviews(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        reviewProtocol.readMyUsefulReviews(userUid: userUid, page: page, itemsPerPage: itemsPerPage)
    }

    func toggleReviewUseful(reviewUid: String, userUid: String) -> AnyPublisher<Bool, Error> {
        reviewProtocol.toggleReviewUseful(reviewUid: reviewUid, userUid: userUid)
    }

    func reportReview(reviewUid: String, reporterUid: String, reportType: String, reportReason: String) -> AnyPublisher<Void, Error> {
        reviewProtocol.reportReview(reviewUid: reviewUid, reporterUid: reporterUid, reportType: reportType, reportReason: reportReason)
    }

    // 🚀 Service만의 추가 기능들
    func getReviewsWithSorting(placeUid: String, sortBy: ReviewListFilterType, page: Int = 1, itemsPerPage: Int = 20) -> AnyPublisher<[ReviewModel], Error> {
        readReviewList(placeUid: placeUid, page: page, itemsPerPage: itemsPerPage)
            .map { [weak self] reviews in
                self?.sortReviews(reviews, by: sortBy) ?? reviews
            }
            .eraseToAnyPublisher()
    }

    private func sortReviews(_ reviews: [ReviewModel], by sortType: ReviewListFilterType) -> [ReviewModel] {
        switch sortType {
        case .new:
            return reviews.sorted { ($0.visitDate ?? "") > ($1.visitDate ?? "") }
        case .recommend:
            return reviews.sorted { ($0.visitDate ?? "") < ($1.visitDate ?? "") }
        case .manyStar:
            return reviews.sorted { $0.usefulCount > $1.usefulCount }
        case .littleStar:
            return reviews.sorted { $0.usefulCount < $1.usefulCount }
        }
    }

    deinit {
        print("✅ ReviewService deinit")
    }
}
