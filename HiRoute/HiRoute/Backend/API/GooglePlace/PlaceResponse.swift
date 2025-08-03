//
//  FeedView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct PlaceResponse: Codable {
    let placeId: String
    let name: String?
    let formattedAddress: String?
    let vicinity: String?
    let geometry: GeometryResponse?
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let types: [String]?
    let openingHours: OpeningHoursResponse?
    let photos: [PhotoResponse]?
    let reviews: [ReviewResponse]?
    let website: String?
    let internationalPhoneNumber: String?
    let formattedPhoneNumber: String?
    let url: String?
    let utcOffset: Int?
    let businessStatus: String?
    let permanentlyClosed: Bool?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case formattedAddress = "formatted_address"
        case vicinity, geometry, rating
        case userRatingsTotal = "user_ratings_total"
        case priceLevel = "price_level"
        case types
        case openingHours = "opening_hours"
        case photos, reviews, website
        case internationalPhoneNumber = "international_phone_number"
        case formattedPhoneNumber = "formatted_phone_number"
        case url
        case utcOffset = "utc_offset"
        case businessStatus = "business_status"
        case permanentlyClosed = "permanently_closed"
    }
}


