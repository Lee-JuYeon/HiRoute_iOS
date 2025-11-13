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
    
    func getAnnotations() -> [AnnotationModel] {
        return [
            AnnotationModel(id: "hospital1", coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), type: .hospital, title: "서울병원", subtitle: nil),

            AnnotationModel(id: "store1", coordinate: CLLocationCoordinate2D(latitude: 37.5655, longitude: 126.9770), type: .store, title: "편의점", subtitle: nil),
            AnnotationModel(id: "cafe1", coordinate: CLLocationCoordinate2D(latitude: 37.5675, longitude: 126.9790), type: .cafe, title: "스타벅스", subtitle: nil),
            AnnotationModel(id: "restaurant1", coordinate: CLLocationCoordinate2D(latitude: 37.5685, longitude: 126.9800), type: .restaurant, title: "맛집", subtitle: nil)
        ]
    }
    
    func getHotPlaces() -> [HotPlaceModel] {
        return HotPlaceView.sampleList
    }
}
