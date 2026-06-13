//
//  ChatMessageRequest.swift
//  HiRoute
//
//  Created by Claude on 5/27/26.
//
//  [2026-05-27 Phase A.1] 채팅 메시지 서버 동기화 DTO.
//  Schedule sync payload에 포함되거나 단일 append endpoint `POST /api/schedules/:uid/chat` 사용.
//  WHY: chatHistory가 클라 전용이라 어제 wipe 사고 시 영구 손실. 이제 서버에도 저장.
//

import Foundation

struct ChatMessageRequest: Encodable {
    let uid: String
    let role: String                   // "user" | "assistant" | "system"
    let content: String
    let attachedPlacesJson: String?    // JSON-encoded [PlaceModel] (nullable)
    let createdAt: String?             // ISO8601
    let deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case uid, role, content
        case attachedPlacesJson = "attached_places_json"
        case createdAt = "created_at"
        case deletedAt = "deleted_at"
    }
}
