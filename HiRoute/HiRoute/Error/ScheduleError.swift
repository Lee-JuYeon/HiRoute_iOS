//
//  RouteUseCase.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Foundation

enum ScheduleError: Error, LocalizedError {
    case noCurrentSchedule
    case updateFailed
    case maxPlacesReached
    case duplicatePlace
    case notFound
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .noCurrentSchedule:
            return "현재 스케줄이 없습니다"
        case .updateFailed:
            return "스케줄 업데이트에 실패했습니다"
        case .maxPlacesReached:
            return "최대 20개의 장소만 추가 가능합니다"
        case .duplicatePlace:
            return "이미 추가된 장소입니다"
        case .notFound:
            return "일정을 찾을 수 없습니다"
        case .networkError:
            return "네트워크 오류"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
}
