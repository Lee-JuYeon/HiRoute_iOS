//
//  EventListModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import Foundation


enum ActivityType : String, Codable {
    case restaurant = "맛집 탐방"
    case cafe = "카페 투어"
    case date = "데이트"
    case anniversary = "특별한 기념일"
    case healing = "산책/힐링"
    case culture = "문화/전시"
    case shopping = "쇼핑"
    
    // 표시용 텍스트
    var displayText: String {
        return self.rawValue
    }
}
