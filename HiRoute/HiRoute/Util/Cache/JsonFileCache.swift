//
//  JsonFileCache.swift
//  HiRoute
//
//  Created by Jupond on 3/14/26.
//

import Foundation

final class JsonFileCache {

    static let shared = JsonFileCache()

    private let cacheDirectory: URL
    private let fileManager = FileManager.default

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("api_responses", isDirectory: true)

        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Save

    func save<T: Codable>(_ data: T, forKey key: String) {
        let entry = CacheFileEntry(data: data, cachedAt: Date().timeIntervalSince1970)
        guard let jsonData = try? JSONEncoder().encode(entry) else { return }
        let fileURL = fileURL(forKey: key)
        try? jsonData.write(to: fileURL, options: [.atomic])
    }

    // MARK: - Load

    func load<T: Codable>(forKey key: String) -> T? {
        let fileURL = fileURL(forKey: key)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return (try? JSONDecoder().decode(CacheFileEntry<T>.self, from: data))?.data
    }

    // MARK: - Remove

    func remove(forKey key: String) {
        try? fileManager.removeItem(at: fileURL(forKey: key))
    }

    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Private

    private func fileURL(forKey key: String) -> URL {
        let sanitized = key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "&", with: "_")
            .replacingOccurrences(of: "=", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return cacheDirectory.appendingPathComponent("\(sanitized).json")
    }
}

private struct CacheFileEntry<T: Codable>: Codable {
    let data: T
    let cachedAt: TimeInterval
}
