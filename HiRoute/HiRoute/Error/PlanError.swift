//
//  PlanError.swift
//  HiRoute
//
//  Created by Jupond on 12/30/25.
//

import Foundation

enum PlanError: Error, LocalizedError {
    case unknown
    case saveFailed
    case planNotFound
    case updateFailed
    case reorderFailed
    case deleteFailed
    case duplicatePlan
    case invalidIndex
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        case .saveFailed:
            return "Plan 저장에 실패했습니다"
        case .planNotFound:
            return "Plan을 찾을 수 없습니다"
        case .updateFailed:
            return "Plan 업데이트에 실패했습니다"
        case .reorderFailed:
            return "Plan 순서 변경에 실패했습니다"
        case .deleteFailed:
            return "Plan 삭제에 실패했습니다"
        case .duplicatePlan:
            return "이미 존재하는 Plan입니다"
        case .invalidIndex:
            return "잘못된 인덱스입니다"
        }
    }
}
