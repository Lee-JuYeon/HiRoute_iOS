//
//  PlaceRepository.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
// MARK: - Repository Implementations
import Foundation
import Combine

class PlaceRepository: PlaceProtocol {

    // MARK: - Cache

    private var cache = NSCache<NSString, AnyObject>()
    private let visitSeoulStore = VisitSeoulPlaceStore.shared

    private static let listKeyPrefix = "place_list"
    private static let detailKeyPrefix = "place_detail_"

    // MARK: - Cache Helpers (NSCache requires AnyObject wrappers for value types)

    private func listCacheKey(page: Int, limit: Int, type: String?, subtype: String?) -> NSString {
        "\(PlaceRepository.listKeyPrefix)_p\(page)_l\(limit)_t\(type ?? "")_s\(subtype ?? "")" as NSString
    }

    private func getCachedPlaces(page: Int, limit: Int, type: String?, subtype: String?) -> [PlaceModel]? {
        (cache.object(forKey: listCacheKey(page: page, limit: limit, type: type, subtype: subtype)) as? PlaceListCacheWrapper)?.places
    }

    private func setCachedPlaces(_ places: [PlaceModel], page: Int, limit: Int, type: String?, subtype: String?) {
        cache.setObject(PlaceListCacheWrapper(places), forKey: listCacheKey(page: page, limit: limit, type: type, subtype: subtype))
    }

    private func getCachedPlace(uid: String) -> PlaceModel? {
        let key = "\(PlaceRepository.detailKeyPrefix)\(uid)" as NSString
        return (cache.object(forKey: key) as? PlaceCacheWrapper)?.place
    }

    private func setCachedPlace(_ place: PlaceModel, uid: String) {
        let key = "\(PlaceRepository.detailKeyPrefix)\(uid)" as NSString
        cache.setObject(PlaceCacheWrapper(place), forKey: key)
    }

    // MARK: - PlaceProtocol

    func createPlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error> {
        // Admin-only operation - return placeholder for now
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    promise(.success(place))
                }
            }
        }.eraseToAnyPublisher()
    }

    func readPlace(placeUid: String) -> AnyPublisher<PlaceModel, Error> {
        if let memCached = getCachedPlace(uid: placeUid) {
            return Just(memCached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let diskCacheKey = "place_detail_\(placeUid)"
        let diskCached: PlaceModel? = JsonFileCache.shared.load(forKey: diskCacheKey)

        let apiPublisher = visitSeoulStore.readPlace(placeUid: placeUid)
            .handleEvents(receiveOutput: { [weak self] model in
                self?.setCachedPlace(model, uid: placeUid)
                JsonFileCache.shared.save(model, forKey: diskCacheKey)
            })
            .eraseToAnyPublisher()

        if let diskCached = diskCached {
            return Just(diskCached)
                .setFailureType(to: Error.self)
                .merge(with: apiPublisher.catch { _ in Empty<PlaceModel, Error>() })
                .eraseToAnyPublisher()
        }

        return apiPublisher
            .eraseToAnyPublisher()
    }

    func readPlaceList(page: Int, itemsPerPage: Int, type: String? = nil, subtype: String? = nil) -> AnyPublisher<[PlaceModel], Error> {
        let apiPage = max(page, 1)

        guard apiPage >= 1, itemsPerPage > 0 else {
            print("PlaceRepository, readPlaceList // Warning : 잘못된 페이지 파라미터 - page:\(page), itemsPerPage:\(itemsPerPage)")
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let diskCacheKey = "place_list_p\(apiPage)_l\(itemsPerPage)_t\(type ?? "")_s\(subtype ?? "")"
        let diskCached: [PlaceModel]? = JsonFileCache.shared.load(forKey: diskCacheKey)

        let apiPublisher = visitSeoulStore.readPlaceList(page: apiPage, itemsPerPage: itemsPerPage)
            .map { models -> [PlaceModel] in
                guard type != nil || subtype != nil else { return models }
                return models.filter { place in
                    let typeMatch = type == nil || place.type.rawValue == type
                    let subtypeMatch = subtype == nil || place.subtype == subtype
                    return typeMatch && subtypeMatch
                }
            }
            .handleEvents(receiveOutput: { [weak self] models in
                self?.setCachedPlaces(models, page: page, limit: itemsPerPage, type: type, subtype: subtype)
                JsonFileCache.shared.save(models, forKey: diskCacheKey)
            })
            .eraseToAnyPublisher()

        if let diskCached = diskCached, apiPage == 1 {
            return Just(diskCached)
                .setFailureType(to: Error.self)
                .merge(with: apiPublisher.catch { _ in Empty<[PlaceModel], Error>() })
                .eraseToAnyPublisher()
        }

        // 캐시 없거나 페이지네이션: API + 캐시 fallback
        return apiPublisher
            .catch { [weak self] error -> AnyPublisher<[PlaceModel], Error> in
                if let diskCached = diskCached {
                    return Just(diskCached).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                if let memCached = self?.getCachedPlaces(page: page, limit: itemsPerPage, type: type, subtype: subtype) {
                    return Just(memCached).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func updatePlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error> {
        // Admin-only operation - return placeholder for now
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    promise(.success(place))
                }
            }
        }.eraseToAnyPublisher()
    }

    func deletePlace(placeUid: String) -> AnyPublisher<PlaceModel, Error> {
        // Admin-only operation - return placeholder for now
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                promise(.failure(ServiceError.unauthorized))
            }
        }.eraseToAnyPublisher()
    }

    func requestPlaceInfoEdit(placeUid: String, userUid: String, reportType: ReportType.RawValue, reason: String) -> AnyPublisher<Void, Error> {
        _ = placeUid
        _ = userUid
        _ = reportType
        _ = reason
        return Fail(error: ServiceError.unsupportedFeature).eraseToAnyPublisher()
    }
}

// MARK: - NSCache Wrappers (NSCache requires AnyObject; PlaceModel is a struct)

private final class PlaceCacheWrapper: NSObject {
    let place: PlaceModel
    init(_ place: PlaceModel) {
        self.place = place
    }
}

private final class PlaceListCacheWrapper: NSObject {
    let places: [PlaceModel]
    init(_ places: [PlaceModel]) {
        self.places = places
    }
}
