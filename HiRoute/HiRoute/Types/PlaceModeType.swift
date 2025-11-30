//
//  PlaceModeType.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//


enum PlaceModeType : String, Codable, CaseIterable {
    case MY = "MY"
    case OTHER = "OTHER"
   
    
    var displayText: String {
        return self.rawValue
    }
}
