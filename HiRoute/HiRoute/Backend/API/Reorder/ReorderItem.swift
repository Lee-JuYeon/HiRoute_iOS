//
//  ReorderItem.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct ReorderItem: Encodable {
    let uid: String
    let indexOrder: Int

    enum CodingKeys: String, CodingKey {
        case uid
        case indexOrder = "index_order"
    }
}
