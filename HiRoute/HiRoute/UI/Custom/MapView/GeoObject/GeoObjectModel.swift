//
//  GeoObjectModel.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import CoreLocation
import UIKit

struct GeoObjectModel: Identifiable {
    enum Style {
        case cube
        case beacon
        case crystal
        case tower
    }

    let id: String
    let title: String
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let style: Style
    let color: UIColor
    let scale: CGFloat
    let altitude: CLLocationDistance
    let isAnimated: Bool

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        coordinate: CLLocationCoordinate2D,
        style: Style,
        color: UIColor,
        scale: CGFloat = 1.0,
        altitude: CLLocationDistance = 0,
        isAnimated: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.style = style
        self.color = color
        self.scale = scale
        self.altitude = altitude
        self.isAnimated = isAnimated
    }
}

extension GeoObjectModel {
    static let sampleList: [GeoObjectModel] = [
        GeoObjectModel(
            id: "nunulala_prompt_gate",
            title: "Prompt Gate",
            subtitle: "세계관 입구",
            coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            style: .beacon,
            color: .systemPink,
            scale: 1.0
        ),
        GeoObjectModel(
            id: "nunulala_trace_crystal",
            title: "Trace Crystal",
            subtitle: "흔적 수집 지점",
            coordinate: CLLocationCoordinate2D(latitude: 37.5704, longitude: 126.9768),
            style: .crystal,
            color: .systemTeal,
            scale: 0.95
        ),
        GeoObjectModel(
            id: "nunulala_world_tower",
            title: "World Tower",
            subtitle: "AR 고정 오브젝트",
            coordinate: CLLocationCoordinate2D(latitude: 37.5638, longitude: 126.9796),
            style: .tower,
            color: .systemPurple,
            scale: 1.05
        )
    ]
}
