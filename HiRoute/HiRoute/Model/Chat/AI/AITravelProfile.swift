//
//  AITravelProfile.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 대화로 파악된 여행 선호 프로필 (서버 TravelProfile).
//
import Foundation

struct AITravelProfile: Codable, Hashable {
    var interests: [String]
    var companions: String?
    var pace: String?
    var budget: String?
    var durationDays: Int?
    var baseArea: String?
    var dietary: [String]

    static let empty = AITravelProfile(
        interests: [], companions: nil, pace: nil, budget: nil,
        durationDays: nil, baseArea: nil, dietary: []
    )
}
