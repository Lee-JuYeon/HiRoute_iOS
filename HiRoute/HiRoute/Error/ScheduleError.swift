//
//  RouteUseCase.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//

enum ScheduleError: Error {
    case notFound
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .notFound: return "일정을 찾을 수 없습니다"
        case .networkError: return "네트워크 오류"
        case .unknown: return "알 수 없는 오류"
        }
    }
}
