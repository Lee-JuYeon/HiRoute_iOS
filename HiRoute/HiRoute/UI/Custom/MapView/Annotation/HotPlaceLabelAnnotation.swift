//
//  HotPlaceLabelAnnotation.swift
//  HiRoute
//
//  Created by Claude on 3/13/26.
//

import MapKit

/// 핫플레이스 중심 좌표에 표시되는 라벨 어노테이션
final class HotPlaceLabelAnnotation: NSObject, MKAnnotation {
    let hotPlace: HotPlaceModel
    let coordinate: CLLocationCoordinate2D
    let title: String?

    init(hotPlace: HotPlaceModel) {
        self.hotPlace = hotPlace

        let coords = hotPlace.coordinates
        let avgLat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
        let avgLon = coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
        self.coordinate = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
        self.title = "\(hotPlace.emoji) \(hotPlace.name)"
        super.init()
    }
}
