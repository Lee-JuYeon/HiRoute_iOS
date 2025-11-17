//
//  PlaceModel.swift
//  HiRoute
//
//  Created by Jupond on 6/26/25.
//
import Foundation

struct AddressModel : Hashable, Codable {
    let addressUID : String // 장소 uid
    let addressLat : Double // 장소 위도
    let addressLon : Double // 장소 경도
    let addressTitle : String // 장소 이름
    let sido : String // 시,도
    let gungu : String // 군,구
    let dong : String // 읍,면,동
    let fullAddress : String // 전체 주소
}
