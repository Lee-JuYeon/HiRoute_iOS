//
//  StoreAPI.swift
//  HiRoute
//
//  Created by Jupond on 8/2/25.
//

import MapKit

protocol MapRepository {
    // Repository: 순수 데이터 가져오기만
    func searchLocation(_ query: String, region: MKCoordinateRegion) async throws -> [MKMapItem]
}
