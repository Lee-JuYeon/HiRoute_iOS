//
//  ScheduleCreateRequest.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct ScheduleCreateRequest: Encodable {
    let uid: String
    let title: String
    let memo: String
    let dDay: String  // ISO8601
    let indexOrder: Int
    let plans: [PlanCreateRequest]
    // [2026-05-27 Phase A.1] chatHistory 서버 동기화 — wipe 사고 영구 손실 방지.
    let chatHistory: [ChatMessageRequest]?

    enum CodingKeys: String, CodingKey {
        case uid, title, memo, plans
        case dDay = "d_day"
        case indexOrder = "index_order"
        case chatHistory = "chat_history"
    }
}
