//
//  PlaceService.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Foundation
import Combine

class PlaceService {
    private let placeProtocol: PlaceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(placeProtocol: PlaceProtocol) {
        self.placeProtocol = placeProtocol
    }
    
    // Repository 메서드 그대로 노출
    func createPlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error> {
        placeProtocol.createPlace(place)
            .handleEvents(receiveOutput: { _ in
                print("📍 Place created: \(place.title)")
            })
            .eraseToAnyPublisher()
    }
    
    func readPlace(placeUID: String) -> AnyPublisher<PlaceModel, Error> {
        placeProtocol.readPlace(placeUID: placeUID)
    }
    
    func readPlaceList(page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error> {
        placeProtocol.readPlaceList(page: page, itemsPerPage: itemsPerPage)
    }
    
    func updatePlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error> {
        placeProtocol.updatePlace(place)
            .handleEvents(receiveOutput: { _ in
                print("📍 Place updated: \(place.title)")
            })
            .eraseToAnyPublisher()
    }
    
    // ✅ 수정: 삭제된 PlaceModel을 반환하도록 변경
    func deletePlace(placeUID: String) -> AnyPublisher<PlaceModel, Error> {
        placeProtocol.deletePlace(placeUID: placeUID)
            .handleEvents(receiveOutput: { deletedPlace in
                print("📍 Place deleted: \(deletedPlace.title) (UID: \(deletedPlace.uid))")
            })
            .eraseToAnyPublisher()
    }
    
    func requestPlaceInfoEdit(placeUID: String, userUID: String, reportType: ReportType.RawValue, reason: String) -> AnyPublisher<Void, Error> {
        placeProtocol.requestPlaceInfoEdit(placeUID: placeUID, userUID: userUID, reportType: reportType, reason: reason)
    }
    
    // 🚀 Service만의 추가 기능들
    func searchPlaces(query: String, page: Int = 1, itemsPerPage: Int = 20) -> AnyPublisher<[PlaceModel], Error> {
        readPlaceList(page: page, itemsPerPage: itemsPerPage)
            .map { places in
                places.filter { place in
                    place.title.localizedCaseInsensitiveContains(query) ||
                    place.subtitle?.localizedCaseInsensitiveContains(query) == true ||
                    place.address.addressTitle.localizedCaseInsensitiveContains(query)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getPopularPlaces(limit: Int = 10) -> AnyPublisher<[PlaceModel], Error> {
        readPlaceList(page: 1, itemsPerPage: 100)
            .map { places in
                places.sorted { $0.bookMarks.count > $1.bookMarks.count }
                    .prefix(limit)
                    .map { $0 }
            }
            .eraseToAnyPublisher()
    }
    
    // 🚀 추가: 삭제 후 로컬 동기화를 위한 편의 메서드
    func deletePlaceAndGetUpdatedList(placeUID: String, page: Int = 1, itemsPerPage: Int = 20) -> AnyPublisher<([PlaceModel], PlaceModel), Error> {
        deletePlace(placeUID: placeUID)
            .flatMap { [weak self] deletedPlace in
                guard let self = self else {
                    return Fail<([PlaceModel], PlaceModel), Error>(error: ServiceError.invalidData)
                        .eraseToAnyPublisher()
                }
                
                return self.readPlaceList(page: page, itemsPerPage: itemsPerPage)
                    .map { updatedList in
                        (updatedList, deletedPlace)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
