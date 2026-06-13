//
//  ScheduleUpdateRequest.swift
//  HiRoute
// 
//  Created by Jupond on 5/5/26.
//

struct ScheduleUpdateRequest: Encodable {
    let title: String?
    let memo: String?
    let dDay: String?
    let plans: [PlanCreateRequest]?
    // [2026-05-27 Phase A.1] chat 서버 동기화 옵션.
    let chatHistory: [ChatMessageRequest]?

    enum CodingKeys: String, CodingKey {
        case title, memo, plans
        case dDay = "d_day"
        case chatHistory = "chat_history"
    }
}
