//
//  PlanResponse.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

import Foundation

struct PlanResponse: Decodable {
    let uid: String
    let scheduleUid: String
    let placeUid: String?
    let indexOrder: Int
    let memo: String
    let createdAt: String
    let updatedAt: String
    let files: [PlanFileResponse]
}


extension PlanResponse {
    func toModel() -> PlanModel {
        let placeModel: PlaceModel
        if let placeUid = placeUid, !placeUid.isEmpty {
            placeModel = PlaceModel(
                uid: placeUid,
                address: .empty(),
                type: .landmark,
                title: ""
            )
        } else {
            placeModel = PlaceModel.empty()
        }

        return PlanModel(
            uid: uid,
            index: indexOrder,
            memo: memo,
            placeModel: placeModel,
            files: files.map { file in
                FileModel.saved(
                    fileName: URL(fileURLWithPath: file.filePath).lastPathComponent,
                    fileType: file.fileType,
                    fileSize: 0,
                    filePath: file.filePath,
                    createdDate: ISO8601DateFormatter().date(from: file.createdAt) ?? Date()
                )
            }
        )
    }
}
