//
//  ReviewProtocol.swift
//  HiRoute
//
//  Created by Jupond on 11/25/25.
//
import Combine

protocol ReviewProtocol {
    
    // 리뷰 생성
    func createReview(placeUID: String, reviewModel: ReviewModel) -> AnyPublisher<ReviewModel, Error>
    
    // 리뷰 수정
    func updateReview(reviewUID: String, reviewModel : ReviewModel) -> AnyPublisher<ReviewModel, Error>
    
    // 리뷰 삭제
    func deleteReview(reviewUID: String) -> AnyPublisher<Void, Error>
    
    // 해당 장소의 리뷰리스트 가져오기
    func readReviewList(placeUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error>
    
    // 내가 쓴 리뷰 리스트 가져오기
    func readMyReviewList(userUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[ReviewModel], Error>
    
    // 도음되요 토글
    func toggleReviewUseful(reviewUID: String, userUID: String) -> AnyPublisher<Bool, Error>
   
    // 리뷰 신고
    func reportReview(reviewUID: String, reporterUID: String, reportType: String, reportReason: String) -> AnyPublisher<Void, Error>
}
