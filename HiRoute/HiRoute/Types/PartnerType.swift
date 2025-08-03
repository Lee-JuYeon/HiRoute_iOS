//
//  FeedModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import Foundation

enum PartnerType : String, Codable {
    case alone = "혼자"
    case friend = "친구(들)과"
    case lover = "연인과"
    case family = "가족과"
    case mate = "동료와"
    case other = "기타"
    
    var displayText: String {
        return self.rawValue
    }
}


