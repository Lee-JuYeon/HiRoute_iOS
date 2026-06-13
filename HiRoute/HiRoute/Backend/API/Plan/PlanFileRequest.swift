//
//  PlanFileRequest.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct PlanFileRequest: Encodable {
    let filePath: String
    let fileType: String

    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
        case fileType = "file_type"
    }
}
