//
//  FeedCreateScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

// place api response
struct PlaceAPIResponse: Codable {
    let candidates: [PlaceResponse]?
    let results: [PlaceResponse]?
    let result: PlaceResponse?
    let status: String
    let errorMessage: String?
    let nextPageToken: String?
    
    enum CodingKeys: String, CodingKey {
        case candidates, results, result, status
        case errorMessage = "error_message"
        case nextPageToken = "next_page_token"
    }
}
