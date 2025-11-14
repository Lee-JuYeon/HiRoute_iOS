//
//  MainDestination.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

enum MainDestination: String, CaseIterable {
    case map = "Map"
    case route = "Route"
    case schedule = "Schedule"
    case myPage = "MyPage"
    
    var title: String {
        switch self {
        case .map: return "지도"
        case .route: return "일정"
        case .schedule: return "일정관리"
        case .myPage: return "마이페이지"
        }
    }
    
    var icon: String {
        switch self {
        case .map: return "map.fill"
        case .route: return "list.bullet"
        case .schedule: return "calendar"
        case .myPage: return "person"
        }
    }
}
