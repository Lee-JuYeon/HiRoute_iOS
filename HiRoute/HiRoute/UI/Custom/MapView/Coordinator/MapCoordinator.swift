//
//  MapCoordinator.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//

import SwiftUI
import MapKit

class MapCoordinator: ObservableObject {
  
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedHotPlaceIds: Set<String> = ["yeonmujang_gil", "garosu_gil", "hongdae"]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let useCase: MapUseCase
    
    init(useCase: MapUseCase) {
        self.useCase = useCase
        loadInitialData()
    }
    
    @Published var annotations: [PlaceModel] = []
    @Published var hotPlaces: [HotPlaceModel] = []
    @Published var recommendPlaces: [PlaceModel] = []
    private func loadInitialData() {
        annotations = useCase.getAnnotations()
        hotPlaces = useCase.getHotPlaces()
        recommendPlaces = useCase.getRecommendPlaces()
    }
      
    
    // 검색 기능
    @Published var searchText: String = ""
    func searchLocation(_ query: String) {
        guard !query.isEmpty else { return }
        
        searchText = query
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let result = try await useCase.searchLocation(query, currentRegion: mapRegion)
                
                searchResults = result.mapItems
                
                if let newRegion = result.newRegion {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        mapRegion = newRegion
                    }
                }
                
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
   
    
    
    // HotPlace 관리 기능들
    func toggleHotPlace(_ id: String) {
        if selectedHotPlaceIds.contains(id) {
            selectedHotPlaceIds.remove(id)
        } else {
            selectedHotPlaceIds.insert(id)
        }
    }
    
    func showAllHotPlaces() {
        selectedHotPlaceIds = Set(hotPlaces.map { $0.id })
        moveToShowAllHotPlaces()
    }
    
    func hideAllHotPlaces() {
        selectedHotPlaceIds.removeAll()
    }
    
    private func moveToShowAllHotPlaces() {
        let allCoordinates = hotPlaces.flatMap { $0.coordinates }
        guard !allCoordinates.isEmpty else { return }
        
        let minLat = allCoordinates.map { $0.latitude }.min() ?? 0
        let maxLat = allCoordinates.map { $0.latitude }.max() ?? 0
        let minLon = allCoordinates.map { $0.longitude }.min() ?? 0
        let maxLon = allCoordinates.map { $0.longitude }.max() ?? 0
        
        withAnimation(.easeInOut(duration: 1.0)) {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (minLat + maxLat) / 2,
                    longitude: (minLon + maxLon) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: (maxLat - minLat) * 1.5,
                    longitudeDelta: (maxLon - minLon) * 1.5
                )
            )
        }
    }
}
