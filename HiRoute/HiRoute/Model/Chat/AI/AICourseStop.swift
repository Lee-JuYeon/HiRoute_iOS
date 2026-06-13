//
//  AICourseStop.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 코스 정류장(방문 순서·이유·좌표·썸네일·주소).
//
import Foundation

struct AICourseStop: Codable, Hashable {
    let placeUid: String
    let name: String
    let order: Int
    let reason: String
    let lat: Double?
    let lon: Double?
    let thumbnailUrl: String?
    let fullAddress: String?
}
