//
//  FileError.swift
//  HiRoute
//
//  Created by Jupond on 12/9/25.
//
import Foundation

enum FileError: Error, LocalizedError {
    case fileTooLarge
    case unsupportedFileType
    case fileNotFound
    case loadFailed
    case saveFailed
    case deleteFailed
    case operationFailed
    case invalidURL
    case compressionFailed
    
    var errorDescription: String? {
        switch self {
        case .fileTooLarge: return "압축 후에도 파일이 너무 큽니다"
        case .unsupportedFileType: return "지원하지 않는 파일 형식입니다"
        case .fileNotFound: return "파일을 찾을 수 없습니다"
        case .loadFailed: return "파일 로드에 실패했습니다"
        case .saveFailed: return "파일 저장에 실패했습니다"
        case .deleteFailed: return "파일 삭제에 실패했습니다"
        case .operationFailed: return "파일 작업에 실패했습니다"
        case .invalidURL: return "잘못된 URL입니다"
        case .compressionFailed: return "파일 압축에 실패했습니다"
        }
    }
}
