//
//  UserRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine

enum ReviewListFilterType : String, Codable {
    case new = "최신순"
    case recommend = "추천순"
    case manyStar = "별점 높은순"
    case littleStar = "별점 낮은순"
    
    var displayText: String {
        return self.rawValue
    }
}

