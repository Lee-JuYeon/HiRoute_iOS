//
//  RouteUseCase.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine
import Foundation

class RouteUseCase {
    private let repository: RouteRepositoryProtocol
       
    init(repository: RouteRepositoryProtocol) {
        self.repository = repository
    }
    
    func getTrendingRoutes(page: Int = 1, itemsPerPage: Int = 10) -> AnyPublisher<[RouteModel], Error> {
        return repository.fetchTrendingRoutes(page: page, itemsPerPage: itemsPerPage)
    }
    
    func getLocalRoutes(page: Int = 1, itemsPerPage: Int = 10) -> AnyPublisher<[RouteModel], Error> {
        return repository.fetchLocalisedRoutes(page: page, itemsPerPage: itemsPerPage)
    }
    
    func getRouteDetail(routeUID: String) -> AnyPublisher<RouteModel, Error> {
        return repository.fetchRouteDetail(routeUID: routeUID)
    }
    
    func searchRoutes(query: String, page: Int = 1, itemsPerPage: Int = 10) -> AnyPublisher<[RouteModel], Error> {
        return repository.searchRoutes(query: query, page: page, itemsPerPage: itemsPerPage)
    }
    
    func updateBookmarks(_ request: BookmarkUpdateRequest) -> AnyPublisher<Void, Error> {
        return repository.updateBookmarks(request)
    }
   
}
