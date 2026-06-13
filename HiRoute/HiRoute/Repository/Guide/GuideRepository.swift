//
//  GuideRepository.swift
//  HiRoute
//
//  Created by Jupond on 4/7/26.
//
import Foundation
import Combine

class GuideRepository: GuideProtocol {

    // MARK: - Cache
    private var cache = NSCache<NSString, GuideListCacheWrapper>()
    private let apiClient = APIClient.shared

    // MARK: - GuideProtocol

    func readGuides(placeUid: String) -> AnyPublisher<[GuideItem], Error> {
        let cacheKey = "guides_\(placeUid)" as NSString

        // Memory cache hit
        if let cached = cache.object(forKey: cacheKey) {
            return Just(cached.guides)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // API call
        let path = "/api/places/\(placeUid)/guides"
        return apiClient.get(path: path)
            .map { (response: APIResponse<[GuideItem]>) -> [GuideItem] in
                let guides = response.data
                self.cache.setObject(GuideListCacheWrapper(guides: guides), forKey: cacheKey)
                return guides
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - NSCache Wrapper (NSCache requires AnyObject; [GuideItem] is a value type)

private final class GuideListCacheWrapper: NSObject {
    let guides: [GuideItem]
    init(guides: [GuideItem]) { self.guides = guides }
}
