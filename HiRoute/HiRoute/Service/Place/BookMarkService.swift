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
    func toggleBookMark(placeUid: String, userUid: String) -> AnyPublisher<Bool, Error> {
        bookMarkProtocol.toggleBookMark(placeUid: placeUid, userUid: userUid)
            .handleEvents(receiveOutput: { [weak self] newState in
                let cacheKey = "\(placeUid)-\(userUid)" as NSString
                self?.cache.setObject(NSNumber(value: newState), forKey: cacheKey)
                print("📌 Bookmark \(newState ? "added" : "removed"): \(placeUid)")
            })
            .eraseToAnyPublisher()
    }
    
    func isPlaceBookMarked(placeUid: String, userUid: String) -> AnyPublisher<Bool, Error> {
        let cacheKey = "\(placeUid)-\(userUid)" as NSString
        
        if let cached = cache.object(forKey: cacheKey) {
            return Just(cached.boolValue)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return bookMarkProtocol.isPlaceBookMarked(placeUid: placeUid, userUid: userUid)
            .handleEvents(receiveOutput: { [weak self] isBookmarked in
                self?.cache.setObject(NSNumber(value: isBookmarked), forKey: cacheKey)
            })
            .eraseToAnyPublisher()
    }
    
    func getPlaceBookMarkCount(placeUid: String) -> AnyPublisher<Int, Error> {
        bookMarkProtocol.getPlaceBookMarkCount(placeUid: placeUid)
    }
    
    func getUserBookMarkPlaces(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error> {
        bookMarkProtocol.getUserBookMarkPlaces(userUid: userUid, page: page, itemsPerPage: itemsPerPage)
    }
    
    // 🚀 Service만의 편의 기능들
    func clearBookmarkCache() {
        cache.removeAllObjects()
    }
    
    func getBookmarkCountForPlaces(_ placeUids: [String]) -> AnyPublisher<[String: Int], Error> {
        let publishers = placeUids.map { placeUid in
            getPlaceBookMarkCount(placeUid: placeUid)
                .map { count in (placeUid, count) }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { Dictionary(uniqueKeysWithValues: $0) }
            .eraseToAnyPublisher()
    }
    
}
