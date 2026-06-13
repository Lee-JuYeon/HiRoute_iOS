//
//  PhotoResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//
import MapKit
import Combine

class MapUseCaseImpl: MapUseCase {
    private let repository: MapRepository
    private let placeStore = VisitSeoulPlaceStore.shared

    init(repository: MapRepository) {
        self.repository = repository
    }

    func searchLocation(_ query: String, currentRegion: MKCoordinateRegion) async throws -> (mapItems: [MKMapItem], newRegion: MKCoordinateRegion?) {
        let mapItems = try await repository.searchLocation(query, region: currentRegion)

        let newRegion: MKCoordinateRegion? = mapItems.first.map { firstResult in
            MKCoordinateRegion(
                center: firstResult.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }

        return (mapItems, newRegion)
    }

    // MARK: - Synchronous (returns cached/empty until API loads)

    func getAnnotations() -> [PlaceModel] {
        // Return empty initially; MapCoordinator will call fetchAnnotationsFromAPI()
        return []
    }

    func getHotPlaces() -> [HotPlaceModel] {
        return HotPlaceModel.sampleList
    }

    func getRecommendPlaces() -> [PlaceModel] {
        // Return empty initially; MapCoordinator will call fetchRecommendPlacesFromAPI()
        return []
    }

    func getGeoObjects() -> [GeoObjectModel] {
        GeoObjectModel.sampleList
    }

    // MARK: - API-based Combine publishers

    /// Fetch place annotations from API for map display (legacy full load)
    func fetchAnnotationsFromAPI() -> AnyPublisher<[PlaceModel], Error> {
        placeStore.readPlaceList(page: 1, itemsPerPage: 100)
    }

    /// Fetch place annotations filtered by viewport (lat/lon/radius, sorted by popularity)
    func fetchAnnotationsForViewport(
        lat: Double,
        lon: Double,
        radius: Int,
        limit: Int = 200
    ) -> AnyPublisher<[PlaceModel], Error> {
        placeStore.readPlaceList(page: 1, itemsPerPage: max(limit, 100))
            .map { places -> [PlaceModel] in
                let radiusInDegrees = Double(radius) / 111000.0
                let filtered = places.filter { place in
                    let placeLat = place.address.lat
                    let placeLon = place.address.lon
                    guard placeLat != 0 || placeLon != 0 else { return false }
                    return abs(placeLat - lat) <= radiusInDegrees && abs(placeLon - lon) <= radiusInDegrees
                }

                if filtered.isEmpty {
                    return Array(places.prefix(limit))
                }
                return Array(filtered.prefix(limit))
            }
            .eraseToAnyPublisher()
    }

    /// Fetch recommended places from API
    func fetchRecommendPlacesFromAPI() -> AnyPublisher<[PlaceModel], Error> {
        placeStore.readPlaceList(page: 1, itemsPerPage: 20)
    }
}
