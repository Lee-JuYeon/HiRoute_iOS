//
//  ReviewProtocol.swift
//  HiRoute
//
//  Created by Jupond on 11/25/25.
//
import Combine

protocol ReviewProtocol {

    // 리뷰 생성
    func createReview(placeUid: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error>

    // 리뷰 수정
    func updateReview(reviewUid: String, reviewModel : ReviewModel) -> AnyPublisher<ReviewModel, Error>

    // 리뷰 삭제
    func deleteReview(reviewUid: String) -> AnyPublisher<Void, Error>

    // 해당 장소의 리뷰리스트 가져오기
    func readReviewList(placeUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error>

    // 내가 쓴 리뷰 리스트 가져오기
    func readMyReviewList(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error>

    // 도움되요 토글
    func toggleReviewUseful(reviewUid: String, userUid: String) -> AnyPublisher<Bool, Error>

    // 내가 도움되요 누른 리뷰 리스트
    func readMyUsefulReviews(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error>

    // 리뷰 신고
    func reportReview(reviewUid: String, reporterUid: String, reportType: String, reportReason: String) -> AnyPublisher<Void, Error>
}
