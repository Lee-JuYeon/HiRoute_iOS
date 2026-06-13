//
//  AIChatHistoryItem.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 서버 세션에 보낼 대화 한 줄 (role/content).
//
import Foundation

struct AIChatHistoryItem: Codable, Hashable {
    let role: String     // "user" | "assistant"
    let content: String
}
