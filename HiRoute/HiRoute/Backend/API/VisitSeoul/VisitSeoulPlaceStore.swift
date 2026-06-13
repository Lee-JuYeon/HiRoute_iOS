//
//  VisitSeoulPlaceStore.swift
//  HiRoute
//
//  Created by Codex on 5/5/26.
//

import Combine
import Foundation

final class VisitSeoulPlaceStore {
    static let shared = VisitSeoulPlaceStore()

    private let client = VisitSeoulAPIClient.shared
    private let memoryCache = NSCache<NSString, PlaceCacheBox>()
    private let listCacheKeyPrefix = "visit_seoul_place_list"
    private let detailCacheKeyPrefix = "visit_seoul_place_detail"

    private init() {}

    func readPlaceList(
        page: Int,
        itemsPerPage: Int,
        comCtgrySn: String? = nil,
        langCodeId: String? = "ko",
        keyword: String? = nil,
        sortType: String = "latest"
    ) -> AnyPublisher<[PlaceModel], Error> {
        let cacheKey = listCacheKey(
            page: page,
            itemsPerPage: itemsPerPage,
            comCtgrySn: comCtgrySn,
            langCodeId: langCodeId,
            keyword: keyword,
            sortType: sortType
        )

        let cached: [PlaceModel]? = JsonFileCache.shared.load(forKey: cacheKey)
        if let cached {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return future {
            let response = try await self.client.fetchContentsList(
                pageNo: page,
                itemsPerPage: itemsPerPage,
                comCtgrySn: comCtgrySn,
                langCodeId: langCodeId,
                keyword: keyword,
                sortType: sortType
            )

            let summaries = response.data
            let indexedPlaces = await self.fetchPlaceModels(from: summaries)
            let places = indexedPlaces
                .sorted { $0.index < $1.index }
                .map { $0.place }

            JsonFileCache.shared.save(places, forKey: cacheKey)
            return places
        }
    }

    func readPlace(placeUid: String) -> AnyPublisher<PlaceModel, Error> {
        if let cached = cachedPlace(uid: placeUid) {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let cacheKey = detailCacheKey(uid: placeUid)
        if let diskCached: PlaceModel = JsonFileCache.shared.load(forKey: cacheKey) {
            cachePlace(diskCached, uid: placeUid)
            return Just(diskCached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return future {
            let response = try await self.client.fetchContentInfo(cid: placeUid)
            let place = Self.map(detail: response.data)
            JsonFileCache.shared.save(place, forKey: cacheKey)
            self.cachePlace(place, uid: placeUid)
            return place
        }
    }

    private func fetchPlaceModels(from summaries: [VisitSeoulContentListDTO]) async -> [(index: Int, place: PlaceModel)] {
        await withTaskGroup(of: (Int, PlaceModel).self) { group in
            for (index, summary) in summaries.enumerated() {
                group.addTask {
                    do {
                        let detailResponse = try await self.client.fetchContentInfo(cid: summary.cid)
                        let place = Self.map(summary: summary, detail: detailResponse.data)
                        return (index, place)
                    } catch {
                        return (index, Self.map(summary: summary))
                    }
                }
            }

            var result: [(Int, PlaceModel)] = []
            for await value in group {
                result.append(value)
            }
            return result
        }
    }

    private func cachedPlace(uid: String) -> PlaceModel? {
        memoryCache.object(forKey: uid as NSString)?.place
    }

    private func cachePlace(_ place: PlaceModel, uid: String) {
        memoryCache.setObject(PlaceCacheBox(place), forKey: uid as NSString)
    }

    private func listCacheKey(
        page: Int,
        itemsPerPage: Int,
        comCtgrySn: String?,
        langCodeId: String?,
        keyword: String?,
        sortType: String
    ) -> String {
        [
            listCacheKeyPrefix,
            "p\(page)",
            "l\(itemsPerPage)",
            "c\(comCtgrySn ?? "")",
            "lang\(langCodeId ?? "")",
            "q\(keyword ?? "")",
            "s\(sortType)"
        ].joined(separator: "_")
    }

    private func detailCacheKey(uid: String) -> String {
        "\(detailCacheKeyPrefix)_\(uid)"
    }

    private func future<T>(_ work: @escaping () async throws -> T) -> AnyPublisher<T, Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        promise(.success(try await work()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private static func map(summary: VisitSeoulContentListDTO) -> PlaceModel {
        map(summary: summary, detail: nil)
    }

    private static func map(detail: VisitSeoulContentInfoDTO) -> PlaceModel {
        let syntheticSummary = VisitSeoulContentListDTO(
            cid: detail.cid,
            langCodeId: detail.langCodeId,
            comCtgrySn: detail.comCtgrySn,
            cateDepth: detail.cateDepth,
            multiLangList: detail.multiLangList,
            mainImg: detail.mainImg,
            postSj: detail.postSj,
            sumry: detail.sumry,
            creatDtText: detail.creatDtText,
            updtDtText: detail.updtDtText
        )
        return map(summary: syntheticSummary, detail: detail)
    }

    private static func map(summary: VisitSeoulContentListDTO, detail: VisitSeoulContentInfoDTO?) -> PlaceModel {
        let title = detail?.postSj ?? summary.postSj ?? ""
        let subtitle = (detail?.sumry ?? summary.sumry ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryDepth = detail?.cateDepth ?? summary.cateDepth
        let leafCategory = categoryDepth?.leafText ?? summary.comCtgrySn ?? "기타"
        let placeType = mappedPlaceType(from: categoryDepth?.joinedText ?? leafCategory)
        let thumbnailURL = detail?.mainImg ?? summary.mainImg ?? ""
        let relateImages = detail?.relateImg ?? []
        let allImages = ([thumbnailURL].filter { !$0.isEmpty } + relateImages)
            .map { ImageModel(id: UUID().uuidString, imageUrl: $0, isAiGenerated: false) }

        let addressText = detail?.traffic?.newAdres
            ?? detail?.traffic?.adres
            ?? ""
        let lat = Double(detail?.traffic?.mapPositionY ?? "") ?? 0
        let lon = Double(detail?.traffic?.mapPositionX ?? "") ?? 0
        let address = AddressModel(
            uid: detail?.cid ?? summary.cid,
            lat: lat,
            lon: lon,
            addressTitle: addressText,
            addressBlock1: addressBlock(addressText, index: 0),
            addressBlock2: addressBlock(addressText, index: 1),
            addressBlock3: addressBlock(addressText, index: 2),
            fullAddress: addressText.isEmpty ? nil : addressText
        )

        return PlaceModel(
            uid: detail?.cid ?? summary.cid,
            address: address,
            type: placeType,
            subtype: summary.comCtgrySn ?? detail?.comCtgrySn,
            typeDisplayText: placeType.displayText,
            subtypeDisplayText: leafCategory,
            title: title,
            subtitle: subtitle.isEmpty ? nil : subtitle,
            thumbnailImage: thumbnailURL.isEmpty ? nil : ImageModel(
                id: detail?.cid ?? summary.cid,
                imageUrl: thumbnailURL,
                isAiGenerated: false
            ),
            workingTimes: nil,
            reviews: [],
            bookMarks: [],
            stars: [],
            placeImages: allImages.isEmpty ? nil : allImages
        )
    }

    private static func mappedPlaceType(from text: String) -> PlaceType {
        let normalized = text.lowercased()

        if normalized.contains("숙박") || normalized.contains("stay") || normalized.contains("hotel") || normalized.contains("guesthouse") {
            return .hotel
        }
        if normalized.contains("음식") || normalized.contains("restaurant") || normalized.contains("food") || normalized.contains("dining") || normalized.contains("맛집") {
            return .restaurant
        }
        if normalized.contains("cafe") || normalized.contains("coffee") || normalized.contains("dessert") || normalized.contains("bakery") {
            return .cafe
        }
        if normalized.contains("쇼핑") || normalized.contains("shopping") || normalized.contains("store") || normalized.contains("market") || normalized.contains("mall") {
            return .store
        }
        if normalized.contains("공원") || normalized.contains("park") || normalized.contains("garden") || normalized.contains("nature") || normalized.contains("trail") {
            return .park
        }
        if normalized.contains("축제") || normalized.contains("공연") || normalized.contains("행사") || normalized.contains("theater") || normalized.contains("performance") || normalized.contains("museum") || normalized.contains("exhibition") {
            return .theater
        }
        if normalized.contains("사찰") || normalized.contains("절") || normalized.contains("temple") || normalized.contains("church") || normalized.contains("cathedral") || normalized.contains("religion") {
            return .temple
        }
        if normalized.contains("병원") || normalized.contains("clinic") || normalized.contains("hospital") {
            return .hospital
        }
        if normalized.contains("약국") || normalized.contains("pharmacy") {
            return .pharmacy
        }
        if normalized.contains("학교") || normalized.contains("school") || normalized.contains("university") {
            return .school
        }
        return .landmark
    }

    private static func addressBlock(_ address: String, index: Int) -> String? {
        let parts = address
            .split(separator: " ")
            .map { String($0) }
            .filter { !$0.isEmpty }
        guard index < parts.count else { return nil }
        return parts[index]
    }
}

private final class PlaceCacheBox: NSObject {
    let place: PlaceModel

    init(_ place: PlaceModel) {
        self.place = place
    }
}
