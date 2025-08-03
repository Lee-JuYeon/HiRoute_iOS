//
//  ReviewResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

struct ReviewResponse: Codable {
    let authorName: String
    let authorUrl: String?
    let language: String?
    let profilePhotoUrl: String?
    let rating: Int
    let relativeTimeDescription: String
    let text: String
    let time: Int
    
    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case authorUrl = "author_url"
        case language
        case profilePhotoUrl = "profile_photo_url"
        case rating
        case relativeTimeDescription = "relative_time_description"
        case text, time
    }
}
