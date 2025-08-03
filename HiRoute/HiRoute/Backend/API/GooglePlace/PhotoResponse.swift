//
//  PhotoResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

struct PhotoResponse: Codable {
    let height: Int
    let width: Int
    let photoReference: String
    let htmlAttributions: [String]
    
    enum CodingKeys: String, CodingKey {
        case height, width
        case photoReference = "photo_reference"
        case htmlAttributions = "html_attributions"
    }
}
