//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//

import Foundation
import Combine

protocol RouteRepositoryProtocol {
    func fetchTrendingRoutes(page: Int, itemsPerPage: Int) -> AnyPublisher<[RouteModel], Error>
    func fetchLocalisedRoutes(page: Int, itemsPerPage: Int) -> AnyPublisher<[RouteModel], Error>
    func fetchRouteDetail(routeUID: String) -> AnyPublisher<RouteModel, Error>
    func searchRoutes(query: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[RouteModel], Error>
    func updateBookmarks(_ request: BookmarkUpdateRequest) -> AnyPublisher<Void, Error>
}


