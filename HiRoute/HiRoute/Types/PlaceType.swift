//
//  AnnotationType.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

enum PlaceType : String, Codable {
    case hospital = "병원"
    case store = "상점"
    case restaurant = "레스토랑"
    case cafe = "카페"
    
    var displayText: String {
        return self.rawValue
    }
}

