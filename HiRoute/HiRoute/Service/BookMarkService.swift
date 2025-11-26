//
//  BookMarkService.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Combine
import Foundation

class BookMarkService {
    private let bookMarkProtocol: BookMarkProtocol
    private let cache = NSCache<NSString, NSNumber>()
    private var cancellables = Set<AnyCancellable>()
    
    init(bookMarkProtocol: BookMarkProtocol) {
        self.bookMarkProtocol = bookMarkProtocol
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 1000
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    // Repository 메서드 + 캐싱 로직
    func toggleBookMark(placeUID: String, userUID: String) -> AnyPublisher<Bool, Error> {
        bookMarkProtocol.toggleBookMark(placeUID: placeUID, userUID: userUID)
            .handleEvents(receiveOutput: { [weak self] newState in
                let cacheKey = "\(placeUID)-\(userUID)" as NSString
                self?.cache.setObject(NSNumber(value: newState), forKey: cacheKey)
                print("📌 Bookmark \(newState ? "added" : "removed"): \(placeUID)")
            })
            .eraseToAnyPublisher()
    }
    
    func isPlaceBookMarked(placeUID: String, userUID: String) -> AnyPublisher<Bool, Error> {
        let cacheKey = "\(placeUID)-\(userUID)" as NSString
        
        if let cached = cache.object(forKey: cacheKey) {
            return Just(cached.boolValue)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return bookMarkProtocol.isPlaceBookMarked(placeUID: placeUID, userUID: userUID)
            .handleEvents(receiveOutput: { [weak self] isBookmarked in
                self?.cache.setObject(NSNumber(value: isBookmarked), forKey: cacheKey)
            })
            .eraseToAnyPublisher()
    }
    
    func getPlaceBookMarkCount(placeUID: String) -> AnyPublisher<Int, Error> {
        bookMarkProtocol.getPlaceBookMarkCount(placeUID: placeUID)
    }
    
    func getUserBookMarkPlaces(userUID: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error> {
        bookMarkProtocol.getUserBookMarkPlaces(userUID: userUID, page: page, itemsPerPage: itemsPerPage)
    }
    
    // 🚀 Service만의 편의 기능들
    func clearBookmarkCache() {
        cache.removeAllObjects()
    }
    
    func getBookmarkCountForPlaces(_ placeUIDs: [String]) -> AnyPublisher<[String: Int], Error> {
        let publishers = placeUIDs.map { placeUID in
            getPlaceBookMarkCount(placeUID: placeUID)
                .map { count in (placeUID, count) }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { Dictionary(uniqueKeysWithValues: $0) }
            .eraseToAnyPublisher()
    }
    
}
