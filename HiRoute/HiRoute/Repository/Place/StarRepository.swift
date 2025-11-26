//
//  StarImplementation.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Foundation
import Combine
class StarRepository: StarProtocol {
    
    func createRate(placeUID: String, userUID: String, star: Int) -> AnyPublisher<StarModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    let starModel = StarModel(userUID: userUID, star: star)
                    promise(.success(starModel))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func removeRate(placeUID: String, userUID: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    func readAverageRate(placeUID: String) -> AnyPublisher<Double, Error> {
        Future { promise in
            DispatchQueue.global().async {
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    let stars = place.stars
                    if stars.isEmpty {
                        promise(.success(0.0))
                    } else {
                        let total = stars.map { $0.star }.reduce(0, +)
                        let average = Double(total) / Double(stars.count)
                        promise(.success(average))
                    }
                } else {
                    promise(.success(0.0))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func readMyRateList(placeUID: String, userUID: String) -> AnyPublisher<Int?, Error> {
        Future { promise in
            DispatchQueue.global().async {
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    let userStar = place.stars.first { $0.userUID == userUID }
                    promise(.success(userStar?.star))
                } else {
                    promise(.success(nil))
                }
            }
        }.eraseToAnyPublisher()
    }
}
