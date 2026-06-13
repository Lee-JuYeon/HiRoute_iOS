//
//  StarDTO.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//

import Foundation

// MARK: - Star Stats DTO (API -> average rating)

struct StarStatsDTO: Decodable {
    let average: Double?
    let total: Int
}
