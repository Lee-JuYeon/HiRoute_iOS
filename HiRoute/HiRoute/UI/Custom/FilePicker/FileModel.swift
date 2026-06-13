//
//  FileModel.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//

import SwiftUI

struct FileModel: Identifiable, Codable, Hashable {
    var id = UUID()
    var data: Data?
    let fileName: String
    let fileType: String
    let fileSize: Int64
    let filePath: String
    let createdDate: Date
    var isAiGenerated: Bool = false

    private static let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "heic", "gif", "webp"]

    var isImageFile: Bool {
        Self.imageExtensions.contains(fileType.lowercased())
    }

    var isPendingUpload: Bool {
        data != nil && filePath.isEmpty
    }

    var isSaved: Bool {
        data == nil && !filePath.isEmpty
    }

    static func forUpload(data: Data, fileName: String, fileType: String, isAiGenerated: Bool = false) -> FileModel {
        return FileModel(
            data: data,
            fileName: fileName,
            fileType: fileType,
            fileSize: Int64(data.count),
            filePath: "",
            createdDate: Date(),
            isAiGenerated: isAiGenerated
        )
    }

    static func saved(fileName: String, fileType: String, fileSize: Int64, filePath: String, createdDate: Date, isAiGenerated: Bool = false) -> FileModel {
        return FileModel(
            data: nil,
            fileName: fileName,
            fileType: fileType,
            fileSize: fileSize,
            filePath: filePath,
            createdDate: createdDate,
            isAiGenerated: isAiGenerated
        )
    }
}
