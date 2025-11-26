//
//  ModeType.swift
//  HiRoute
//
//  Created by Jupond on 11/25/25.
//

enum ModeType : String, Codable, CaseIterable {
    case READ = "READ"
    case ADD = "ADD"
    case EDIT = "EDIT"
    
    var displayText: String {
        return self.rawValue
    }
}


