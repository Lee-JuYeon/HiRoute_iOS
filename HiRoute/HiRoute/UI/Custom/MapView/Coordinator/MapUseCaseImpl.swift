//
//  PhotoResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//
import MapKit

class MapUseCaseImpl: MapUseCase {
    private let repository: MapRepository
    
    init(repository: MapRepository) {
        self.repository = repository
    }
    
    func searchLocation(_ query: String, currentRegion: MKCoordinateRegion) async throws -> (mapItems: [MKMapItem], newRegion: MKCoordinateRegion?) {
        let mapItems = try await repository.searchLocation(query, region: currentRegion)
        
        // 첫 번째 결과로 지도 이동
        let newRegion: MKCoordinateRegion? = mapItems.first.map { firstResult in
            MKCoordinateRegion(
                center: firstResult.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
        
        return (mapItems, newRegion)
    }
    
    func getAnnotations() -> [PlaceModel] {
        return DummyPack.sampleAnnotations
    }
    
    func getHotPlaces() -> [HotPlaceModel] {
        return HotPlaceView.sampleList
    }
    
    func getRecommendPlaces() -> [PlaceModel] {
        return DummyPack.samplePlaces
    }
}
