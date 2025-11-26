//
//  PlanUseCase.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine

protocol BookMarkProtocol {
    // 1. 북마크 on/off 토글
    func toggleBookMark(placeUID: String, userUID: String) -> AnyPublisher<Bool, Error>
    
    // 2. 북마크 상태 확인 (내가 북마크했는지)
    func isPlaceBookMarked(placeUID: String, userUID: String) -> AnyPublisher<Bool, Error>
    
    // 3. 북마크 개수 (이 장소를 몇 명이 북마크했는지)
    func getPlaceBookMarkCount(placeUID: String) -> AnyPublisher<Int, Error>

    // 4. 내가 북마크한 장소 목록 (마이페이지용)
    func getUserBookMarkPlaces(userUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error>

}

