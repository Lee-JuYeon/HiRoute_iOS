//
//  AnnotationType.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

enum PlaceType : String, Codable, CaseIterable {
    case hospital = "hospital"
    case store = "store"
    case restaurant = "restaurant"
    case cafe = "cafe"
    case park = "park"
    case theater = "theater"
    case hotel = "hotel"
    case school = "school"
    case landmark = "landmark"
    case temple = "temple"
    case pharmacy = "pharmacy"

    // 알 수 없는 타입 → 디코딩 실패 방지
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = PlaceType(rawValue: value) ?? .landmark
    }

    var displayText: String {
        switch self {
        case .hospital: return "병원"
        case .store: return "상점"
        case .restaurant: return "레스토랑"
        case .cafe: return "카페"
        case .park: return "공원"
        case .theater: return "공연장"
        case .hotel: return "숙소"
        case .school: return "학교"
        case .landmark: return "유적지"
        case .temple: return "종교시설"
        case .pharmacy: return "약국"
        }
    }
}
