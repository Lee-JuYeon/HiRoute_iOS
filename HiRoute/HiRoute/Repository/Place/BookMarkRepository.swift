//
//  ReviewImplementation.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Combine
import Foundation

class BookMarkRepository: BookMarkProtocol {
    
    func toggleBookMark(placeUID: String, userUID: String) -> AnyPublisher<Bool, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let isBookmarked = Bool.random()
                    promise(.success(isBookmarked))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func isPlaceBookMarked(placeUID: String, userUID: String) -> AnyPublisher<Bool, Error> {
        Future { promise in
            DispatchQueue.global().async {
                // DummyPack에서 확인
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    let isBookmarked = place.bookMarks.contains { $0.userUID == userUID }
                    promise(.success(isBookmarked))
                } else {
                    promise(.success(false))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getPlaceBookMarkCount(placeUID: String) -> AnyPublisher<Int, Error> {
        Future { promise in
            DispatchQueue.global().async {
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    promise(.success(place.bookMarks.count))
                } else {
                    promise(.success(0))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getUserBookMarkPlaces(userUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                let bookmarkedPlaces = DummyPack.samplePlaces.filter { place in
                    place.bookMarks.contains { $0.userUID == userUID }
                }
                
                let startIndex = (page - 1) * itemsPerPage
                let endIndex = min(startIndex + itemsPerPage, bookmarkedPlaces.count)
                
                guard startIndex < bookmarkedPlaces.count else {
                    promise(.success([]))
                    return
                }
                
                let pageData = Array(bookmarkedPlaces[startIndex..<endIndex])
                promise(.success(pageData))
            }
        }.eraseToAnyPublisher()
    }
}
