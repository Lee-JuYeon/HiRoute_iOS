//
//  PlaceHighLightCell.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import MapKit
import SwiftUI

struct HotPlaceModel {
    let id: String
    let name: String
    let emoji: String
    let coordinates: [CLLocationCoordinate2D]
    let color: Color
    let description: String
    
    init(id: String, name: String, emoji: String, coordinates: [CLLocationCoordinate2D], color: Color = .green, description: String = "") {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.coordinates = coordinates
        self.color = color
        self.description = description
    }
}

// MARK: - 샘플 데이터
extension HotPlaceModel {
    static let sampleList: [HotPlaceModel] = [
        HotPlaceModel(
            id: "yeonmujang_gil",
            name: "연무장길",
            emoji: "🔥",
            coordinates: [
                CLLocationCoordinate2D(latitude: 37.5440, longitude: 127.0550),
                CLLocationCoordinate2D(latitude: 37.5442, longitude: 127.0552),
                CLLocationCoordinate2D(latitude: 37.5445, longitude: 127.0555),
                CLLocationCoordinate2D(latitude: 37.5447, longitude: 127.0557),
                CLLocationCoordinate2D(latitude: 37.5449, longitude: 127.0559),
                CLLocationCoordinate2D(latitude: 37.5452, longitude: 127.0562),
                CLLocationCoordinate2D(latitude: 37.5454, longitude: 127.0565),
                CLLocationCoordinate2D(latitude: 37.5453, longitude: 127.0563),
                CLLocationCoordinate2D(latitude: 37.5451, longitude: 127.0560),
                CLLocationCoordinate2D(latitude: 37.5448, longitude: 127.0558),
                CLLocationCoordinate2D(latitude: 37.5446, longitude: 127.0556),
                CLLocationCoordinate2D(latitude: 37.5443, longitude: 127.0553),
                CLLocationCoordinate2D(latitude: 37.5441, longitude: 127.0551),
            ],
            color: .green,
            description: "성수동 트렌디한 카페와 브런치 거리"
        ),
        HotPlaceModel(
            id: "garosu_gil",
            name: "가로수길",
            emoji: "🌳",
            coordinates: [
                CLLocationCoordinate2D(latitude: 37.5195, longitude: 127.0230),
                CLLocationCoordinate2D(latitude: 37.5200, longitude: 127.0235),
                CLLocationCoordinate2D(latitude: 37.5205, longitude: 127.0240),
                CLLocationCoordinate2D(latitude: 37.5210, longitude: 127.0245),
                CLLocationCoordinate2D(latitude: 37.5215, longitude: 127.0250),
                CLLocationCoordinate2D(latitude: 37.5213, longitude: 127.0248),
                CLLocationCoordinate2D(latitude: 37.5208, longitude: 127.0243),
                CLLocationCoordinate2D(latitude: 37.5203, longitude: 127.0238),
                CLLocationCoordinate2D(latitude: 37.5198, longitude: 127.0233),
                CLLocationCoordinate2D(latitude: 37.5196, longitude: 127.0232),
            ],
            color: .orange,
            description: "신사동 패션과 카페의 거리"
        ),
        HotPlaceModel(
            id: "hongdae",
            name: "홍대 놀이터",
            emoji: "🎵",
            coordinates: [
                CLLocationCoordinate2D(latitude: 37.5563, longitude: 126.9233),
                CLLocationCoordinate2D(latitude: 37.5568, longitude: 126.9238),
                CLLocationCoordinate2D(latitude: 37.5573, longitude: 126.9243),
                CLLocationCoordinate2D(latitude: 37.5578, longitude: 126.9248),
                CLLocationCoordinate2D(latitude: 37.5583, longitude: 126.9253),
                CLLocationCoordinate2D(latitude: 37.5581, longitude: 126.9251),
                CLLocationCoordinate2D(latitude: 37.5576, longitude: 126.9246),
                CLLocationCoordinate2D(latitude: 37.5571, longitude: 126.9241),
                CLLocationCoordinate2D(latitude: 37.5566, longitude: 126.9236),
                CLLocationCoordinate2D(latitude: 37.5565, longitude: 126.9235),
            ],
            color: .purple,
            description: "청춘과 문화의 거리"
        ),
        HotPlaceModel(
            id: "itaewon",
            name: "이태원 거리",
            emoji: "🌍",
            coordinates: [
                CLLocationCoordinate2D(latitude: 37.5344, longitude: 126.9944),
                CLLocationCoordinate2D(latitude: 37.5349, longitude: 126.9949),
                CLLocationCoordinate2D(latitude: 37.5354, longitude: 126.9954),
                CLLocationCoordinate2D(latitude: 37.5359, longitude: 126.9959),
                CLLocationCoordinate2D(latitude: 37.5364, longitude: 126.9964),
                CLLocationCoordinate2D(latitude: 37.5362, longitude: 126.9962),
                CLLocationCoordinate2D(latitude: 37.5357, longitude: 126.9957),
                CLLocationCoordinate2D(latitude: 37.5352, longitude: 126.9952),
                CLLocationCoordinate2D(latitude: 37.5347, longitude: 126.9947),
                CLLocationCoordinate2D(latitude: 37.5346, longitude: 126.9946),
            ],
            color: .blue,
            description: "글로벌 문화와 맛집의 거리"
        ),
        HotPlaceModel(
            id: "gangnam",
            name: "강남역",
            emoji: "✨",
            coordinates: [
                CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276),
                CLLocationCoordinate2D(latitude: 37.4984, longitude: 127.0281),
                CLLocationCoordinate2D(latitude: 37.4989, longitude: 127.0286),
                CLLocationCoordinate2D(latitude: 37.4994, longitude: 127.0291),
                CLLocationCoordinate2D(latitude: 37.4999, longitude: 127.0296),
                CLLocationCoordinate2D(latitude: 37.4997, longitude: 127.0294),
                CLLocationCoordinate2D(latitude: 37.4992, longitude: 127.0289),
                CLLocationCoordinate2D(latitude: 37.4987, longitude: 127.0284),
                CLLocationCoordinate2D(latitude: 37.4982, longitude: 127.0279),
                CLLocationCoordinate2D(latitude: 37.4981, longitude: 127.0278),
            ],
            color: .pink,
            description: "트렌디한 쇼핑과 엔터테인먼트의 중심"
        ),
    ]
}
