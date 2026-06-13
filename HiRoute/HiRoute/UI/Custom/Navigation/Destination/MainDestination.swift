//
//  MainDestination.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

enum MainDestination: String, CaseIterable {
    case planner = "Planner"
    case map = "Map"
    case route = "Route"
    case schedule = "Schedule"
    case stationMap = "StationMap"
    case emergency = "Emergency"
    case myPage = "MyPage"

    var title: String {
        switch self {
        case .planner: return "일정짜기"
        case .map: return "지도"
        case .route: return "일정"
        case .schedule: return "일정"
        case .stationMap: return "역내비"
        case .emergency: return "응급"
        case .myPage: return "마이페이지"
        }
    }

    var icon: String {
        switch self {
        case .planner: return "bubble.left.and.bubble.right.fill"
        case .map: return "map.fill"
        case .route: return "list.bullet"
        case .schedule: return "list.bullet"
        case .stationMap: return "building.fill"
        case .emergency: return "cross.case.fill"
        case .myPage: return "person"
        }
    }
}
