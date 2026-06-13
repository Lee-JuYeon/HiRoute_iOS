//
//  AINearRestaurant.swift
//  HiRoute
//
//  [2026-06-07] AI 챗 연동: 특정장소 근처 맛집(좌표·썸네일·주소=실제값).
//
import Foundation

struct AINearRestaurant: Codable, Hashable {
    let placeUid: String
    let name: String
    let distKm: Double
    let lat: Double
    let lon: Double
    let thumbnailUrl: String?
    let fullAddress: String?
}
