//
//  AIChatPlaceFactory.swift
//  HiRoute
//
//  [2026-06-07] AI 응답의 코스/맛집 → 지도핀·카드용 PlaceModel 변환 (썸네일·주소 포함).
//  썸네일은 http(visitkorea)면 https 로 업그레이드(ATS 우회).
//
import Foundation

enum AIChatPlaceFactory {
    private static func secureImageURL(_ raw: String?) -> ImageModel? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        let https = raw.hasPrefix("http://") ? "https://" + raw.dropFirst("http://".count) : raw
        return ImageModel(id: "img_\(https.hashValue)", imageUrl: https)
    }

    static func make(uid: String, name: String, lat: Double, lon: Double, type: PlaceType,
                     subtitle: String?, thumbnailUrl: String?, fullAddress: String?) -> PlaceModel {
        PlaceModel(
            uid: uid,
            address: AddressModel(
                uid: "addr_\(uid)", lat: lat, lon: lon,
                addressTitle: name, addressBlock1: nil, addressBlock2: nil, addressBlock3: nil,
                fullAddress: fullAddress
            ),
            type: type,
            title: name,
            subtitle: subtitle,
            thumbnailImage: secureImageURL(thumbnailUrl)
        )
    }
    static func fromCourse(_ s: AICourseStop) -> PlaceModel? {
        guard let lat = s.lat, let lon = s.lon else { return nil }
        return make(uid: s.placeUid, name: s.name, lat: lat, lon: lon, type: .landmark,
                    subtitle: s.reason, thumbnailUrl: s.thumbnailUrl, fullAddress: s.fullAddress)
    }
    static func fromDining(_ d: AIDiningSpot) -> PlaceModel {
        make(uid: d.placeUid, name: d.name, lat: d.lat, lon: d.lon, type: .restaurant,
             subtitle: "\(d.nearStop) 근처 · \(String(format: "%.1f", d.distKm))km",
             thumbnailUrl: d.thumbnailUrl, fullAddress: d.fullAddress)
    }
    static func fromRestaurant(_ r: AINearRestaurant) -> PlaceModel {
        make(uid: r.placeUid, name: r.name, lat: r.lat, lon: r.lon, type: .restaurant,
             subtitle: "\(String(format: "%.1f", r.distKm))km",
             thumbnailUrl: r.thumbnailUrl, fullAddress: r.fullAddress)
    }
}
