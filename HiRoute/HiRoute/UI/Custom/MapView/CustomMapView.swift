//
//  CustomMapView.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import SwiftUI
import MapKit

/*
 CLLocationCoordinate2D : 위도 경도를 나타내는 구조체, 지구상의 특정 위치를 표현
 MKCoordinateSpan : 지도에서 보여줄 범위 (확대/축소정도)를 나타내는 구조체
 center : 지도의 중심점, 지도가 처음 로드될 때 화면 중앙에 표시될 위치
 span : 지도의 표시 범위,MKCoordinateSpan타입으로 지정, 지도에서 얼마나 넓은 영역을 보여줄지 경정
 */

struct MapAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    
    enum AnnotationType {
        case search(MKMapItem)
        case store(Store)
    }
}

struct CustomMapView : View {
    
    @Binding var region: MKCoordinateRegion
    let searchResults: [MKMapItem]
    let hotPlaces: [HotPlaceModel]
    @State var selectedHotPlaceIds: Set<String>

    @State private var hasInitializedLocation = false
    @State private var selectedStore: Store?

    
    // 중앙 핀의 위도경도 (지도 중심과 동일)
    @State private var centerPinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
 
   
    // 모든 어노테이션 통합
    private var allAnnotations: [MapAnnotation] {
        var annotations: [MapAnnotation] = []
        
        // 검색 결과
        annotations += searchResults.map {
            MapAnnotation(id: UUID().uuidString, coordinate: $0.placemark.coordinate, type: .search($0))
        }
    
        
        return annotations
    }
    
    @ViewBuilder
    private func annotationView(for annotation: MapAnnotation) -> some View {
        switch annotation.type {
        case .search(let mapItem):
            VStack {
                Image(systemName: "pin.fill")
                    .foregroundColor(.blue)
                Text(mapItem.name ?? "")
                    .font(.caption)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
            }
        case .store(let store):
            Button(action: { selectedStore = store }) {
                Image(systemName: "mappin")
                    .font(.title3)
                    .foregroundColor(.red)
                    .shadow(radius: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    
    @ViewBuilder
    private func hotPlaceOverlays() -> some View {
        ForEach(hotPlaces, id: \.id) { hotPlace in
            if selectedHotPlaceIds.contains(hotPlace.id) {
                HotPlaceView(coordinates: hotPlace.coordinates, region: region, color: hotPlace.color)
                
                if let centerCoordinate = getCenterCoordinate(from: hotPlace.coordinates) {
                    VStack {
                        Text("\(hotPlace.emoji) \(hotPlace.name)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(hotPlace.color)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .position(coordinateToScreenPoint(centerCoordinate))
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: allAnnotations, id: \.id) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    annotationView(for: annotation)
                }
            }
            .onAppear {
                searchVM.requestLocationPermission()
            }
            
            hotPlaceOverlays()
        }
    }
}

func getCenterCoordinate(from coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return nil }
        
        let totalLat = coordinates.reduce(0) { $0 + $1.latitude }
        let totalLon = coordinates.reduce(0) { $0 + $1.longitude }
        let count = Double(coordinates.count)
        
        return CLLocationCoordinate2D(
            latitude: totalLat / count,
            longitude: totalLon / count
        )
    }
    
    func coordinateToScreenPoint(_ coordinate: CLLocationCoordinate2D) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let centerLat = region.center.latitude
        let centerLon = region.center.longitude
        let latSpan = region.span.latitudeDelta
        let lonSpan = region.span.longitudeDelta
        
        let relativeX = (coordinate.longitude - centerLon) / lonSpan
        let relativeY = (centerLat - coordinate.latitude) / latSpan
        
        let x = screenWidth * (0.5 + relativeX)
        let y = screenHeight * (0.5 + relativeY)
        
        return CGPoint(x: x, y: y)
    }
