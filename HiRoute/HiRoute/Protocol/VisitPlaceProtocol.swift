//
//  FeedRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import Foundation
import Combine


protocol VisitPlaceProtocol {
    func createVisitPlaceModel(_ model: VisitPlaceModel) -> AnyPublisher<VisitPlaceModel, Error>
    func readVisitPlaceModel(visitPlaceUID: String) -> AnyPublisher<VisitPlaceModel, Error>
    func readVisitPlaceModelList(page: Int, itemsPerPage: Int) -> AnyPublisher<[VisitPlaceModel], Error>
    func updateVisitPlaceModel(_ model: VisitPlaceModel) -> AnyPublisher<VisitPlaceModel, Error>
    func deleteVisitPlaceModel(visitPlaceUID: String) -> AnyPublisher<Void, Error>
}
