//
//  ScheduleDTO.swift
//  HiRoute
//
//  Created by Jupond on 3/19/26.
//

import Foundation

enum VisitSeoulAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case apiError(code: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "비짓서울 API 응답을 해석할 수 없습니다."
        case .httpStatus(let status):
            return "비짓서울 API HTTP 오류: \(status)"
        case .apiError(_, let message):
            return message
        }
    }
}
