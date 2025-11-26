//
//  FileModel.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//

import SwiftUI

struct FileModel: Identifiable, Codable, Hashable {
    var id = UUID()
    let fileName: String
    let fileType: String
    let fileSize: Int64
    let filePath: String
    let createdDate: Date
}
