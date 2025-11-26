//
//  BookMarkImplementation.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
enum ServiceError: Error {
    case dataNotFound
    case invalidData
    case networkError
    case unauthorized
    
    var localizedDescription: String {
        switch self {
        case .dataNotFound:
            return "데이터를 찾을 수 없습니다"
        case .invalidData:
            return "잘못된 데이터입니다"
        case .networkError:
            return "네트워크 오류가 발생했습니다"
        case .unauthorized:
            return "권한이 없습니다"
        }
    }
}
