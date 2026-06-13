//
//  ScheduleSyncUpdateItem.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct ScheduleSyncUpdateItem: Encodable {
    let uid: String
    let title: String?
    let memo: String?
    let dDay: String?
    let plans: [PlanCreateRequest]?
    let chatHistory: [ChatMessageRequest]?  // [2026-05-27 Phase A.1]
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case uid, title, memo, plans
        case dDay = "d_day"
        case chatHistory = "chat_history"
        case updatedAt = "updated_at"
    }
}
