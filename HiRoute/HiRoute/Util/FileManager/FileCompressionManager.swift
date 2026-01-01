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
 * FileCompressionManager (확실한 방법)
 * - iOS SDK에서 확실히 동작하는 API만 사용
 * - 실제 압축 기능 구현
 */
class FileCompressionManager {
    static let shared = FileCompressionManager()
    
    private init() {
        print("FileCompressionManager, init // Success : 파일 압축 매니저 초기화")
    }
    
    /**
     * 파일 타입별 압축
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
     */
    func compressImage(data: Data, quality: CGFloat) -> Data {
        guard let image = UIImage(data: data) else { return data }
        return image.jpegData(compressionQuality: quality) ?? data
    }
    
    // MARK: - Private Compression Methods
    
    /**
     * JPEG 압축
     */
    private func compressJPEG(data: Data, quality: CGFloat) -> Data {
        guard let image = UIImage(data: data) else {
            print("FileCompressionManager, compressJPEG // Warning : 이미지 디코딩 실패")
            return data
        }
        
        if let compressedData = image.jpegData(compressionQuality: quality) {
            let compressionRatio = Double(data.count) / Double(compressedData.count)
            print("FileCompressionManager, compressJPEG // Success : JPEG 압축 완료 - 압축률: \(String(format: "%.1f", compressionRatio))x")
            return compressedData
        }
        
        return data
    }
    
    /**
     * PNG 압축 (해상도 조정)
     */
    private func compressPNG(data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        
        let originalSize = image.size
        let maxDimension: CGFloat = 2048
        
        if max(originalSize.width, originalSize.height) > maxDimension {
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
     * PDF 압축 (확실한 방법)
     */
    private func compressPDF(data: Data) -> Data {
        guard let pdfDocument = PDFDocument(data: data) else {
            print("FileCompressionManager, compressPDF // Warning : PDF 디코딩 실패")
            return data
        }
        
        // ✅ 확실한 방법: 기본 데이터 표현
        if let compressedData = pdfDocument.dataRepresentation() {
            let compressionRatio = Double(data.count) / Double(compressedData.count)
            print("FileCompressionManager, compressPDF // Success : PDF 압축 완료 - 압축률: \(String(format: "%.1f", compressionRatio))x")
            return compressedData
        }
        
        return data
    }
    
    /**
     * 텍스트 압축 (Foundation API 사용)
     */
    private func compressText(data: Data) -> Data {
        do {
            // ✅ 확실한 방법: Foundation의 NSData compression
            let compressedData = try (data as NSData).compressed(using: .lzfse) as Data
            let compressionRatio = Double(data.count) / Double(compressedData.count)
            print("FileCompressionManager, compressText // Success : 텍스트 압축 완료 - 압축률: \(String(format: "%.1f", compressionRatio))x")
            return compressedData
        } catch {
            print("FileCompressionManager, compressText // Warning : 텍스트 압축 실패 - \(error.localizedDescription)")
            return data
        }
    }
    
    /**
     * 문서 압축
     */
    private func compressDocument(data: Data) -> Data {
        return compressText(data: data) // 동일한 LZFSE 압축
    }
    
    /**
     * 텍스트 압축 해제
     */
    private func decompressText(data: Data) -> Data {
        do {
            let decompressedData = try (data as NSData).decompressed(using: .lzfse) as Data
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
