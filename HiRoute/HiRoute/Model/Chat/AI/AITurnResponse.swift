//
//  AITurnResponse.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 한 턴 응답. type 으로 분기.
//  type: "rejected" | "answer" | "clarify" | "near_place" | "recommendation"
//
import Foundation

struct AITurnResponse: Codable, Hashable {
    let type: String

    let message: String?       // rejected
    let text: String?          // answer (설명)
    let placeName: String?     // answer 참고 장소명
    let question: String?      // clarify
    let profile: AITravelProfile?   // clarify / recommendation
    let anchor: String?        // near_place
    let restaurants: [AINearRestaurant]?  // near_place
    let recommendation: AIRecommendation? // recommendation

    enum Kind: String {
        case rejected, answer, clarify, nearPlace = "near_place", recommendation
    }
    var kind: Kind? { Kind(rawValue: type) }
}
