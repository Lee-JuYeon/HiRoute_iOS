//
//  GeoObjectAnnotation.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import MapKit

final class GeoObjectAnnotation: NSObject, MKAnnotation {
    let geoObject: GeoObjectModel
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(geoObject: GeoObjectModel) {
        self.geoObject = geoObject
        self.coordinate = geoObject.coordinate
        self.title = geoObject.title
        self.subtitle = geoObject.subtitle
        super.init()
    }
}
