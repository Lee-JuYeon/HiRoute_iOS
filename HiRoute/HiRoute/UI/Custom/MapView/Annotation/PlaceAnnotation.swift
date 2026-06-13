//
//  PlaceAnnotation.swift
//  HiRoute
//
//  Created by Claude on 3/13/26.
//

import MapKit

/// PlaceModel을 감싸는 MKAnnotation (MKMapView용)
final class PlaceAnnotation: NSObject, MKAnnotation {
    let placeModel: PlaceModel
    let coordinate: CLLocationCoordinate2D
    let title: String?

    init(placeModel: PlaceModel) {
        self.placeModel = placeModel
        self.coordinate = CLLocationCoordinate2D(
            latitude: placeModel.address.lat,
            longitude: placeModel.address.lon
        )
        self.title = placeModel.title
        super.init()
    }
}
