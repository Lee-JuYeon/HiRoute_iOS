//
//  FileCacheManager.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//
import SwiftUI
import MobileCoreServices

class FileCacheManager {
    static let shared = FileCacheManager()
    
    private let cacheDirectory: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("FileCache")
        
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    func saveFile(from url: URL) -> FileModel? {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            let fileExtension = url.pathExtension.lowercased()
            let uniqueFileName = "\(UUID().uuidString)_\(fileName)"
            let destinationURL = cacheDirectory.appendingPathComponent(uniqueFileName)
            
            try data.write(to: destinationURL)
            
            let fileSize = try FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64 ?? 0
            
            return FileModel(
                fileName: fileName,
                fileType: fileExtension,
                fileSize: fileSize,
                filePath: destinationURL.path,
                createdDate: Date()
            )
        } catch {
            print("파일 저장 실패: \(error)")
            return nil
        }
    }
    
    func loadFile(fileModel: FileModel) -> Data? {
        return try? Data(contentsOf: URL(fileURLWithPath: fileModel.filePath))
    }
    
    func deleteFile(fileModel: FileModel) {
        try? FileManager.default.removeItem(atPath: fileModel.filePath)
    }
}
