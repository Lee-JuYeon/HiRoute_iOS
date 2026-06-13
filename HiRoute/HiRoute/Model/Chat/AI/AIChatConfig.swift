//
//  AIChatConfig.swift
//  HiRoute
//
//  [2026-06-08] AI 챗 백엔드 = Cloudflare(nunulala-api Workers AI). prod.
//  POST https://api.nunulala.com/api/ai/chat. (로컬 dev 서버는 AI_CHAT_BASE_URL 로 override.)
//
import Foundation

enum AIChatConfig {
    static let prodBaseURL = "https://api.nunulala.com"

    /// 환경변수 AI_CHAT_BASE_URL 있으면 우선(로컬 dev), 없으면 Cloudflare 프로덕션.
    static var baseURL: URL {
        if let s = ProcessInfo.processInfo.environment["AI_CHAT_BASE_URL"], let u = URL(string: s) {
            return u
        }
        return URL(string: prodBaseURL)!
    }
    static var chatEndpoint: URL { baseURL.appendingPathComponent("api/ai/chat") }
}
