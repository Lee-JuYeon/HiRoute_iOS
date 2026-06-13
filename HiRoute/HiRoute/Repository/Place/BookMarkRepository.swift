//
//  BookMarkRepository.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Combine
import Foundation

private struct BookMarkToggleResponse: Decodable {
    let bookmarked: Bool
}

private struct BookMarkStatusResponse: Decodable {
    let bookmarked: Bool
}

private struct BookMarkCountResponse: Decodable {
    let count: Int
}

class BookMarkRepository: BookMarkProtocol {

    private var cache = NSCache<NSString, AnyObject>()


    func toggleBookMark(placeUid: String, userUid: String) -> AnyPublisher<Bool, Error> {
        let publisher: AnyPublisher<APIResponse<BookMarkToggleResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/places/\(placeUid)/bookmark", body: EmptyBody())

        return publisher
            .map { response in response.data.bookmarked }
            .eraseToAnyPublisher()
    }

    func isPlaceBookMarked(placeUid: String, userUid: String) -> AnyPublisher<Bool, Error> {
        let publisher: AnyPublisher<APIResponse<BookMarkStatusResponse>, Error> =
            APIClient.shared.getWithAuth(path: "/api/places/\(placeUid)/bookmark/status")

        return publisher
            .map { response in response.data.bookmarked }
            .catch { _ -> AnyPublisher<Bool, Error> in
                // 오프라인 fallback: 로컬 DB 확인
                Future { promise in
                    LocalDB.shared.isBookmarked(userUid: userUid, placeUid: placeUid) { isBookmarked in
                        promise(.success(isBookmarked))
                    }
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getPlaceBookMarkCount(placeUid: String) -> AnyPublisher<Int, Error> {
        let publisher: AnyPublisher<APIResponse<BookMarkCountResponse>, Error> =
            APIClient.shared.get(path: "/api/places/\(placeUid)/bookmark/count")

        return publisher
            .map { response in
                response.data.count
            }
            .eraseToAnyPublisher()
    }

    func getUserBookMarkPlaces(userUid: String, page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error> {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(itemsPerPage)")
        ]

        let diskCacheKey = "bookmarks_\(userUid)_p\(page)_l\(itemsPerPage)"

        let publisher: AnyPublisher<APIResponse<[PlaceModel]>, Error> =
            APIClient.shared.getWithAuth(path: "/api/users/\(userUid)/bookmarks", queryItems: queryItems)

        return publisher
            .map { response in response.data }
            .handleEvents(receiveOutput: { models in
                JsonFileCache.shared.save(models, forKey: diskCacheKey)
            })
            .catch { error -> AnyPublisher<[PlaceModel], Error> in
                if let cached: [PlaceModel] = JsonFileCache.shared.load(forKey: diskCacheKey) {
                    return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
