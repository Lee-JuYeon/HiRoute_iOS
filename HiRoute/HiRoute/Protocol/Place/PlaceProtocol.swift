//
//  RouteDestination.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import Combine

protocol PlaceProtocol {
    // 생성
    func createPlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error>
    
    // 해당 모델 가져오기
    func readPlace(placeUID: String) -> AnyPublisher<PlaceModel, Error>
    
    // 리스트 가져오기
    func readPlaceList(page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error>
    
    // 수정
    func updatePlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error>
    
    // 삭제
    func deletePlace(placeUID: String) -> AnyPublisher<PlaceModel, Error>
       
    // 정보 수정 제안
    func requestPlaceInfoEdit(placeUID: String, userUID: String, reportType : ReportType.RawValue, reason: String) -> AnyPublisher<Void, Error>
    

}
