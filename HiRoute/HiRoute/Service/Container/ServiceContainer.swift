//
//  Untitled.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//

class ServiceContainer {
    
    // MARK: - Lazy Loading
    lazy var placeService = PlaceService(placeProtocol: PlaceRepository())
    lazy var bookMarkService = BookMarkService(bookMarkProtocol: BookMarkRepository())
    lazy var reviewService = ReviewService(reviewProtocol: ReviewRepository())
    lazy var starService = StarService(starProtocol: StarRepository())
    
    // MARK: - Singleton
    static let shared = ServiceContainer()
    private init() {}
}
