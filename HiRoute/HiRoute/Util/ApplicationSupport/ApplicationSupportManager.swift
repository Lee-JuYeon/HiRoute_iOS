//
//  ApplicationSupportManager.swift
//  HiRoute
//
//  Created by Codex on 5/8/26.
//

import Foundation

/// 앱 내부 Application Support 폴더를 관리한다.
/// 오프라인에서도 유지되어야 하는 퀘스트 리소스는 Caches가 아니라 이 위치에 저장한다.
final class ApplicationSupportManager {
    static let shared = ApplicationSupportManager()

    private let fileManager = FileManager.default
    private let questAssetRootName = "QuestAssets"

    private init() {}

    /// Application Support/QuestAssets 루트 폴더.
    func questAssetRootDirectory() throws -> URL {
        let applicationSupportURL = try applicationSupportDirectory()
        let rootURL = applicationSupportURL.appendingPathComponent(questAssetRootName, isDirectory: true)
        try createDirectoryIfNeeded(at: rootURL)
        return rootURL
    }

    /// 특정 퀘스트의 타입별 리소스 저장 폴더.
    func questAssetDirectory(questId: String, assetType: QuestAssetType) throws -> URL {
        let questDirectory = try questAssetRootDirectory().appendingPathComponent(questId, isDirectory: true)
        let directory = questDirectory.appendingPathComponent(assetType.folderName, isDirectory: true)
        try createDirectoryIfNeeded(at: directory)
        return directory
    }

    /// Data를 퀘스트 리소스 파일로 저장하고, DB에 넣기 좋은 상대경로를 반환한다.
    func saveQuestAsset(data: Data, questId: String, assetType: QuestAssetType, fileName: String) throws -> String {
        let fileURL = try questAssetDirectory(questId: questId, assetType: assetType).appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return try relativePath(for: fileURL)
    }

    /// 임시 파일을 Application Support로 이동하고, DB에 넣기 좋은 상대경로를 반환한다.
    func moveQuestAsset(from sourceURL: URL, questId: String, assetType: QuestAssetType, fileName: String) throws -> String {
        let destinationURL = try questAssetDirectory(questId: questId, assetType: assetType).appendingPathComponent(fileName)

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.moveItem(at: sourceURL, to: destinationURL)
        return try relativePath(for: destinationURL)
    }

    /// DB에 저장된 상대경로를 실제 파일 URL로 변환한다.
    func absoluteURL(forRelativePath relativePath: String) -> URL {
        let baseURL = (try? applicationSupportDirectory()) ?? fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        return baseURL.appendingPathComponent(relativePath)
    }

    func fileExists(relativePath: String?) -> Bool {
        guard let relativePath else { return false }
        return fileManager.fileExists(atPath: absoluteURL(forRelativePath: relativePath).path)
    }

    func removeFile(relativePath: String?) throws {
        guard let relativePath else { return }
        let fileURL = absoluteURL(forRelativePath: relativePath)

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    private func applicationSupportDirectory() throws -> URL {
        let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try createDirectoryIfNeeded(at: url)
        return url
    }

    private func createDirectoryIfNeeded(at url: URL) throws {
        guard !fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func relativePath(for fileURL: URL) throws -> String {
        let baseURL = try applicationSupportDirectory()
        let basePath = baseURL.path + "/"
        return fileURL.path.replacingOccurrences(of: basePath, with: "")
    }
}
