//
//  FeedCreateScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import MapKit

protocol MapUseCase {
    
    // UseCase: 비즈니스 로직 추가할 예정.
    func searchLocation(_ query: String, currentRegion: MKCoordinateRegion) async throws -> (mapItems: [MKMapItem], newRegion: MKCoordinateRegion?)
    func getAnnotations() -> [PlaceModel]
    func getHotPlaces() -> [HotPlaceModel]
    func getRecommendPlaces() -> [PlaceModel]
}
