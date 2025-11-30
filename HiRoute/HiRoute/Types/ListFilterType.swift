//
//  Untitled.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//

enum ListFilterType : String, Codable, CaseIterable {
    case DEFAULT = "정렬순"
    case NEWEST = "최신순"
    case OLDEST = "오래된 순"
    
    var displayText: String {
        return self.rawValue
    }
}
