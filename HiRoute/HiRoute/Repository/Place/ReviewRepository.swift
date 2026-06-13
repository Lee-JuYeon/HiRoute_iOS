//
//  ReviewRepository.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Foundation
import Combine

private struct ReviewCreateBody: Encodable {
    let reviewText: String?
    let visitDate: String?
    let rating: Int

    enum CodingKeys: String, CodingKey {
        case reviewText = "review_text"
        case visitDate = "visit_date"
        case rating
    }
}

private struct ReviewUpdateBody: Encodable {
    let reviewText: String?
    let visitDate: String?
    let rating: Int?

    enum CodingKeys: String, CodingKey {
        case reviewText = "review_text"
        case visitDate = "visit_date"
        case rating
    }
}

private struct ReviewDeleteResponse: Decodable {
    let message: String
}

private struct ReportBody: Encodable {
    let reportType: String
    let reportReason: String

    enum CodingKeys: String, CodingKey {
        case reportType = "report_type"
        case reportReason = "report_reason"
    }
}

private struct ReportCreateResponse: Decodable {
    let id: Int
}

class ReviewRepository: ReviewProtocol {

    private var cache = NSCache<NSString, AnyObject>()

    func createReview(placeUid: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        let body = ReviewCreateBody(
            reviewText: reviewModel.reviewText,
            visitDate: reviewModel.visitDate,
            rating: reviewModel.rating
        )
        let publisher: AnyPublisher<APIResponse<ReviewModel>, Error> =
            APIClient.shared.postWithAuth(path: "/api/places/\(placeUid)/reviews", body: body)

        return publisher
            .map { response in response.data }
            .eraseToAnyPublisher()
    }

    func updateReview(reviewUid: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error> {
        let body = ReviewUpdateBody(
            reviewText: reviewModel.reviewText,
            visitDate: reviewModel.visitDate,
            rating: reviewModel.rating
        )
        let publisher: AnyPublisher<APIResponse<ReviewModel>, Error> =
            APIClient.shared.putWithAuth(path: "/api/reviews/\(reviewUid)", body: body)

        return publisher
            .map { response in response.data }
            .eraseToAnyPublisher()
    }

    func deleteReview(reviewUid: String) -> AnyPublisher<Void, Error> {
        let publisher: AnyPublisher<APIResponse<ReviewDeleteResponse>, Error> =
            APIClient.shared.deleteWithAuth(path: "/api/reviews/\(reviewUid)")

        return publisher
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func readReviewList(placeUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(itemsPerPage)")
        ]

        let diskCacheKey = "review_list_\(placeUid)_p\(page)_l\(itemsPerPage)"

        let publisher: AnyPublisher<APIResponse<[ReviewModel]>, Error> =
            APIClient.shared.get(path: "/api/places/\(placeUid)/reviews", queryItems: queryItems)

        return publisher
            .map { response in response.data }
            .handleEvents(receiveOutput: { models in
                JsonFileCache.shared.save(models, forKey: diskCacheKey)
            })
            .catch { error -> AnyPublisher<[ReviewModel], Error> in
                if let cached: [ReviewModel] = JsonFileCache.shared.load(forKey: diskCacheKey) {
                    return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func readMyReviewList(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(itemsPerPage)")
        ]

        let diskCacheKey = "my_reviews_\(userUid)_p\(page)_l\(itemsPerPage)"

        let publisher: AnyPublisher<APIResponse<[ReviewModel]>, Error> =
            APIClient.shared.getWithAuth(path: "/api/users/\(userUid)/reviews", queryItems: queryItems)

        return publisher
            .map { response in response.data }
            .handleEvents(receiveOutput: { models in
                JsonFileCache.shared.save(models, forKey: diskCacheKey)
            })
            .catch { error -> AnyPublisher<[ReviewModel], Error> in
                if let cached: [ReviewModel] = JsonFileCache.shared.load(forKey: diskCacheKey) {
                    return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func readMyUsefulReviews(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error> {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(itemsPerPage)")
        ]

        let diskCacheKey = "my_usefuls_\(userUid)_p\(page)_l\(itemsPerPage)"

        let publisher: AnyPublisher<APIResponse<[ReviewModel]>, Error> =
            APIClient.shared.getWithAuth(path: "/api/users/\(userUid)/usefuls", queryItems: queryItems)

        return publisher
            .map { response in response.data }
            .handleEvents(receiveOutput: { models in
                JsonFileCache.shared.save(models, forKey: diskCacheKey)
            })
            .catch { error -> AnyPublisher<[ReviewModel], Error> in
                if let cached: [ReviewModel] = JsonFileCache.shared.load(forKey: diskCacheKey) {
                    return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func toggleReviewUseful(reviewUid: String, userUid: String) -> AnyPublisher<Bool, Error> {
        let publisher: AnyPublisher<APIResponse<UsefulToggleResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/reviews/\(reviewUid)/useful", body: EmptyBody())

        return publisher
            .map { response in
                response.data.toggled
            }
            .eraseToAnyPublisher()
    }

    func reportReview(reviewUid: String, reporterUid: String, reportType: String, reportReason: String) -> AnyPublisher<Void, Error> {
        let body = ReportBody(reportType: reportType, reportReason: reportReason)
        let publisher: AnyPublisher<APIResponse<ReportCreateResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/reviews/\(reviewUid)/report", body: body)

        return publisher
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
