//
//  StarProtocol.swift
//  HiRoute
//
//  Created by Jupond on 11/25/25.
//
import Combine

protocol StarProtocol {
    
    // 별점 추가
    func createRate(placeUID: String, userUID: String, star: Int) -> AnyPublisher<StarModel, Error>
    
    // 별점 쥐소
    func removeRate(placeUID: String, userUID: String) -> AnyPublisher<Void, Error>
    
    // 해당 장소의 평균 별점
    func readAverageRate(placeUID: String) -> AnyPublisher<Double, Error>
    
    // 내가 평가한 해당 장소의 별점
    func readMyRateList(placeUID: String, userUID: String) -> AnyPublisher<Int?, Error>
}
