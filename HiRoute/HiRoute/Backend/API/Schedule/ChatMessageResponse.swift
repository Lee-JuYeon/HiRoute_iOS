//
//  ChatMessageResponse.swift
//  HiRoute
//
//  Created by Claude on 5/27/26.
//
//  [2026-05-27 Phase A.1] 서버 응답 — 채팅 메시지 1건.
//  APIClient 디코더는 keyDecodingStrategy=.convertFromSnakeCase 적용 → CodingKeys rawValue는
//  변환 후 camelCase 형태여야 함 (PlanFileResponse 픽스와 동일 패턴).
//

import Foundation

struct ChatMessageResponse: Decodable {
    let uid: String
    let scheduleUid: String
    let role: String
    let content: String
    let attachedPlacesJson: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case uid
        case scheduleUid          // "schedule_uid" → convert → "scheduleUid"
        case role
        case content
        case attachedPlacesJson   // "attached_places_json" → convert → "attachedPlacesJson"
        case createdAt
        case updatedAt
        case deletedAt
    }
}
