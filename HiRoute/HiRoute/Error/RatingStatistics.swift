//
//  ServiceContainer.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//

struct RatingStatistics {
    let placeUID: String
    let averageRating: Double
    let totalRatings: Int
    let distribution: [Int: Int] // rating: count
}
