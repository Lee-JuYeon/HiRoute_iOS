//
//  GuideItem.swift
//  HiRoute
//
//  Created by Jupond on 5/6/26.
//

struct GuideItem: Codable, Identifiable, Hashable {
    var id: String { uid }
    let uid: String
    let placeUid: String
    let title: String
    var icon: String?
    let indexOrder: Int
    let blocks: [ContentBlock]

    static func empty() -> GuideItem {
        GuideItem(uid: "", placeUid: "", title: "", indexOrder: 0, blocks: [])
    }
}
