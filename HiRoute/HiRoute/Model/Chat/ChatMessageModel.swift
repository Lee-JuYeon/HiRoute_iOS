//
//  ChatMessageModel.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import Foundation

struct ChatMessageModel: Codable, Identifiable, Hashable {
    var id: String { uid }

    let uid: String
    let role: ChatRole
    let content: String
    let createdAt: Date
    /// AI 응답에 첨부된 장소 목록 (장소 간략히 보기 카드용). user 메시지는 항상 nil.
    let attachedPlaces: [PlaceModel]?
    /// AI 추천 코스 (코스 전용 카드 렌더용). 추천 응답에만 존재. [2026-06-07]
    let recommendation: AIRecommendation?

    init(
        uid: String,
        role: ChatRole,
        content: String,
        createdAt: Date,
        attachedPlaces: [PlaceModel]? = nil,
        recommendation: AIRecommendation? = nil
    ) {
        self.uid = uid
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.attachedPlaces = attachedPlaces
        self.recommendation = recommendation
    }
}
