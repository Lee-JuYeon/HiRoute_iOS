//
//  NetworkError.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다"
        case .noData:
            return "데이터가 없습니다"
        case .decodingError:
            return "데이터 파싱 오류입니다"
        case .serverError(let code):
            return "서버 오류 (코드: \(code))"
        case .networkUnavailable:
            return "네트워크 연결을 확인해주세요"
        }
    }
}
