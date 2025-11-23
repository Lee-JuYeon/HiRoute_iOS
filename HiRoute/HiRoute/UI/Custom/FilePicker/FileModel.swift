//
//  FileModel.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//

import SwiftUI

struct FileModel: Hashable, Identifiable, Codable {
    var id: String
    var fileName: String
    var filePath: String
    var fileSize: Int64
    var fileType: String
    var createdDate: Date
}
