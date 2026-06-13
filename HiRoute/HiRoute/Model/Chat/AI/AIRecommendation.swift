//
//  AIRecommendation.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 추천 코스(테마+동선응집 코스+좌표계산 근처맛집).
//
import Foundation

struct AIRecommendation: Codable, Hashable {
    let theme: String
    let city: String
    let coherenceKm: Double
    let course: [AICourseStop]
    let diningNearCourse: [AIDiningSpot]
}
