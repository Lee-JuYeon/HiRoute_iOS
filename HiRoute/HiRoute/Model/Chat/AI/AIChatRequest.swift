//
//  AIChatRequest.swift
//  HiRoute
//
//  [2026-06-07] POST /chat 요청 바디 { message, session }.
//
import Foundation

struct AIChatRequest: Codable {
    let message: String
    let session: AIChatSession
}
