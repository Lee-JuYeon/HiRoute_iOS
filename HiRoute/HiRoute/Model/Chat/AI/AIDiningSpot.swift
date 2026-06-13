//
//  AIDiningSpot.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 코스 stop 근처 맛집(near_stop·거리·썸네일·주소).
//
import Foundation

struct AIDiningSpot: Codable, Hashable {
    let nearStop: String
    let placeUid: String
    let name: String
    let distKm: Double
    let lat: Double
    let lon: Double
    let thumbnailUrl: String?
    let fullAddress: String?
}
