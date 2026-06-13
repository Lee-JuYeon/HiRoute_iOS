//
//  StarProtocol.swift
//  HiRoute
//
//  Created by Jupond on 11/25/25.
//
import Combine

protocol StarProtocol {

    // 별점 추가
    func createRate(placeUid: String, userUid: String, star: Int) -> AnyPublisher<StarModel, Error>

    // 별점 제거
    func removeRate(placeUid: String, userUid: String) -> AnyPublisher<Void, Error>

    // 해당 장소의 평균 별점
    func readAverageRate(placeUid: String) -> AnyPublisher<Double, Error>

    // 내가 평가한 해당 장소의 별점
    func readMyRateList(placeUid: String, userUid: String) -> AnyPublisher<Int?, Error>
}
