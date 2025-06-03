//
//  MainDestination.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

enum MainDestination: String, CaseIterable {
    case home = "Home"
    case feed = "Feed"
    case schedule = "Schedule"
    case myPage = "MyPage"
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .feed: return "일정피드"
        case .schedule: return "일정관리"
        case .myPage: return "마이페이지"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .feed: return "list.bullet"
        case .schedule: return "calendar"
        case .myPage: return "person"
        }
    }
}
