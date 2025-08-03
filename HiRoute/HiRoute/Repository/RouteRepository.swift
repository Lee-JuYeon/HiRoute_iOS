//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine
import Foundation

class RouteRepository: RouteRepositoryProtocol {

    func fetchTrendingRoutes(page: Int, itemsPerPage: Int) -> AnyPublisher<[RouteModel], Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                let mockRoutes = DummyPack.shared.samplePlans[0].visitRoutes
                promise(.success(mockRoutes))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchLocalisedRoutes(page: Int, itemsPerPage: Int) -> AnyPublisher<[RouteModel], Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let mockRoutes = DummyPack.shared.samplePlans[1].visitRoutes
                promise(.success(mockRoutes))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchRouteDetail(routeUID: String) -> AnyPublisher<RouteModel, Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                if let route = DummyPack.shared.samplePlans[0].visitRoutes.first {
                    promise(.success(route))
                } else {
                    promise(.failure(NetworkError.noData))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func searchRoutes(query: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[RouteModel], Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                let allRoutes = DummyPack.shared.samplePlans[0].visitRoutes
                let filteredRoutes = allRoutes.filter {
                    $0.routeTitle.contains(query) || $0.routeType.contains(query)
                }
                promise(.success(Array(filteredRoutes.prefix(itemsPerPage))))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateBookmarks(_ request: BookmarkUpdateRequest) -> AnyPublisher<Void, Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                print("🌐 서버 북마크 업데이트 완료:")
                for change in request.changes {
                    print("  • \(change.routeUID): \(change.isBookmarked ? "ON" : "OFF")")
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
   
}
