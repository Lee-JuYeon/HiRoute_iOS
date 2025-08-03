//
//  PlaceModel.swift
//  HiRoute
//
//  Created by Jupond on 6/26/25.
//
import Foundation

struct AddressModel : Hashable, Codable {
    var addressUID : String // 장소 uid
    var addressTitle : String // 장소 이름
    var addressLat : Double // 장소 위도
    var addressLon : Double // 장소 경도
    var sido : String // 시,도
    var gungu : String // 군,구
    var dong : String // 읍,면,동
    var fullAddress : String // 전체 주소
}
