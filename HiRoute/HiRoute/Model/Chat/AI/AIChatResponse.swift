//
//  AIChatResponse.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: POST /chat 최상위 응답 { response, session }.
//
import Foundation

struct AIChatResponse: Codable {
    let response: AITurnResponse
    let session: AIChatSession
}
