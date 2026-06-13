//
//  PlanCreateRequest.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//


struct PlanCreateRequest: Encodable {
    let uid: String
    let placeUid: String?
    let indexOrder: Int
    let memo: String
    let files: [PlanFileRequest]

    enum CodingKeys: String, CodingKey {
        case uid, memo, files
        case placeUid = "place_uid"
        case indexOrder = "index_order"
    }
}
