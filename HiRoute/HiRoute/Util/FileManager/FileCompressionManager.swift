//
//  OfflineOperation.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

import Foundation
import UIKit
import PDFKit

/**
 * FileCompressionManager
 * - 파일 무손실/손실 압축 싱글톤
 * - 이미지, PDF, 텍스트 파일 압축 지원
 * - 사용자 편의성: 용량 제한 에러 대신 자동 압축
 */
class FileCompressionManager {
    static let shared = FileCompressionManager()
    
    private init() {
        print("FileCompressionManager, init // Success : 파일 압축 매니저 초기화")
    }
    
    /**
     * 파일 타입별 압축
     * @param data: 원본 파일 데이터
     * @param fileType: 파일 확장자
     * @return: 압축된 파일 데이터
     */
    func compressFile(data: Data, fileType: String) -> Data {
        let type = fileType.lowercased()
        
        switch type {
        case "jpg", "jpeg":
            return compressJPEG(data: data, quality: 0.7)
        case "png":
            return compressPNG(data: data)
        case "gif":
            return data // GIF는 이미 압축됨
        case "pdf":
            return compressPDF(data: data)
        case "txt":
            return compressText(data: data)
        case "doc", "docx":
            return compressDocument(data: data)
        default:
            return data
        }
    }
    
    /**
     * 압축 해제
     * @param data: 압축된 파일 데이터
     * @param fileType: 파일 확장자
     * @return: 원본 파일 데이터
     */
    func decompressFile(data: Data, fileType: String) -> Data {
        let type = fileType.lowercased()
        
        switch type {
        case "txt":
            return decompressText(data: data)
        case "doc", "docx":
            return decompressDocument(data: data)
        default:
            return data // 이미지, PDF는 압축해제 불필요
        }
    }
    
    /**
     * 이미지 압축 (캐시용)
     * @param data: 이미지 데이터
     * @param quality: 압축 품질 (0.0 ~ 1.0)
     */
    func compressImage(data: Data, quality: CGFloat) -> Data {
        guard let image = UIImage(data: data) else { return data }
        
        // JPEG로 압축
        return image.jpegData(compressionQuality: quality) ?? data
    }
    
    // MARK: - Private Compression Methods
    
    /**
     * JPEG 이미지 압축
     */
    private func compressJPEG(data: Data, quality: CGFloat) -> Data {
        guard let image = UIImage(data: data) else {
            print("FileCompressionManager, compressJPEG // Warning : 이미지 디코딩 실패")
            return data
        }
        
        // 품질 조정하여 압축
        if let compressedData = image.jpegData(compressionQuality: quality) {
            let compressionRatio = Double(data.count) / Double(compressedData.count)
            print("FileCompressionManager, compressJPEG // Success : JPEG 압축 완료 - 압축률: \(String(format: "%.1f", compressionRatio))x")
            return compressedData
        }
        
        return data
    }
    
    /**
     * PNG 이미지 최적화
     * - PNG는 무손실이므로 크기 조정으로 용량 최적화
     */
    private func compressPNG(data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        
        let originalSize = image.size
        let maxDimension: CGFloat = 2048 // 최대 해상도 제한
        
        if max(originalSize.width, originalSize.height) > maxDimension {
            // 해상도 조정
            let scale = maxDimension / max(originalSize.width, originalSize.height)
            let newSize = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let resizedData = resizedImage?.pngData() {
                print("FileCompressionManager, compressPNG // Success : PNG 해상도 최적화 - \(originalSize) → \(newSize)")
                return resizedData
            }
        }
        
        return data
    }
    
    /**
     * PDF 압축
     */
    private func compressPDF(data: Data) -> Data {
        guard let pdfDocument = PDFDocument(data: data) else {
            print("FileCompressionManager, compressPDF // Warning : PDF 디코딩 실패")
            return data
        }
        
        // PDF 최적화 옵션
        let writeOptions: [PDFDocumentWriteOption: Any] = [
            .optimizeImagesForScreen: true
        ]
        
        if let compressedData = pdfDocument.dataRepresentation(options: writeOptions) {
            let compressionRatio = Double(data.count) / Double(compressedData.count)
            print("FileCompressionManager, compressPDF // Success : PDF 압축 완료 - 압축률: \(String(format: "%.1f", compressionRatio))x")
            return compressedData
        }
        
        return data
    }
    
    /**
     * 텍스트 파일 압축 (gzip)
     */
    private func compressText(data: Data) -> Data {
        do {
            let compressedData = try data.compressed(using: .gzip)
            let compressionRatio = Double(data.count) / Double(compressedData.count)
            print("FileCompressionManager, compressText // Success : 텍스트 압축 완료 - 압축률: \(String(format: "%.1f", compressionRatio))x")
            return compressedData
        } catch {
            print("FileCompressionManager, compressText // Warning : 텍스트 압축 실패 - \(error.localizedDescription)")
            return data
        }
    }
    
    /**
     * 문서 파일 압축 (gzip)
     */
    private func compressDocument(data: Data) -> Data {
        return compressText(data: data) // 동일한 gzip 압축
    }
    
    /**
     * 텍스트 압축 해제
     */
    private func decompressText(data: Data) -> Data {
        do {
            let decompressedData = try data.decompressed(using: .gzip)
            print("FileCompressionManager, decompressText // Success : 텍스트 압축해제 완료")
            return decompressedData
        } catch {
            print("FileCompressionManager, decompressText // Warning : 압축해제 실패, 원본 반환")
            return data // 압축되지 않은 파일일 수 있음
        }
    }
    
    /**
     * 문서 압축 해제
     */
    private func decompressDocument(data: Data) -> Data {
        return decompressText(data: data)
    }
}

// MARK: - Data Extension for Compression
extension Data {
    func compressed(using algorithm: NSData.CompressionAlgorithm) throws -> Data {
        return try self.withUnsafeBytes { bytes in
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
            defer { buffer.deallocate() }
            
            let compressedSize = compression_encode_buffer(
                buffer, count,
                bytes.bindMemory(to: UInt8.self).baseAddress!, count,
                nil, algorithm.rawValue
            )
            
            guard compressedSize > 0 else {
                throw FileError.compressionFailed
            }
            
            return Data(bytes: buffer, count: compressedSize)
        }
    }
    
    func decompressed(using algorithm: NSData.CompressionAlgorithm) throws -> Data {
        return try self.withUnsafeBytes { bytes in
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count * 4)
            defer { buffer.deallocate() }
            
            let decompressedSize = compression_decode_buffer(
                buffer, count * 4,
                bytes.bindMemory(to: UInt8.self).baseAddress!, count,
                nil, algorithm.rawValue
            )
            
            guard decompressedSize > 0 else {
                throw FileError.compressionFailed
            }
            
            return Data(bytes: buffer, count: decompressedSize)
        }
    }
}
