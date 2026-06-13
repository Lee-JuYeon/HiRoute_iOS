//
//  AIChatSession.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 대화 상태(프로필+히스토리). 클라가 보관·재전송(영구저장).
//
import Foundation

struct AIChatSession: Codable, Hashable {
    var profile: AITravelProfile
    var history: [AIChatHistoryItem]

    static let empty = AIChatSession(profile: .empty, history: [])
}
