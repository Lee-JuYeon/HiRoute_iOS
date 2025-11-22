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
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("FileCache")
        
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func saveFile(from sourceURL: URL) -> FileModel? {
        guard sourceURL.startAccessingSecurityScopedResource() else { return nil }
        defer { sourceURL.stopAccessingSecurityScopedResource() }
        
        let fileName = sourceURL.lastPathComponent
        let fileID = UUID().uuidString
        let destinationURL = cacheDirectory.appendingPathComponent("\(fileID)_\(fileName)")
        
        do {
            let fileData = try Data(contentsOf: sourceURL)
            try fileData.write(to: destinationURL)
            
            return FileModel(
                id: fileID,
                fileName: fileName,
                filePath: destinationURL.path,
                fileSize: Int64(fileData.count),
                fileType: sourceURL.pathExtension,
                createdDate: Date()
            )
        } catch {
            print("파일 저장 실패: \(error)")
            return nil
        }
    }
    
    func loadFile(fileModel: FileModel) -> Data? {
        let fileURL = URL(fileURLWithPath: fileModel.filePath)
        return try? Data(contentsOf: fileURL)
    }
}
