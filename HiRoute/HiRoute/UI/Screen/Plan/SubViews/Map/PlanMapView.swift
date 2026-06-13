//
//  RootDetailChartView.swift
//  HiRoute
//
//  Created by Jupond on 7/18/25.
//

import SwiftUI
import MapKit


struct PlanMapView : View {

    private var getPlanList: [PlanModel]
    @EnvironmentObject private var scheduleVM: ScheduleVM

    init(
        setVisitPlaceList: [PlanModel]
    ) {
        self.getPlanList = setVisitPlaceList
    }
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    
    // 지도 영역을 방문 장소들에 맞게 설정
    private func setupMapRegion() {
        guard !getPlanList.isEmpty else { return }
        
        let coordinates = getPlanList.map { visitPlace in
            CLLocationCoordinate2D(
                latitude: visitPlace.placeModel.address.lat,
                longitude: visitPlace.placeModel.address.lon
            )
        }
        
        let minLat = coordinates.map(\.latitude).min() ?? 0
        let maxLat = coordinates.map(\.latitude).max() ?? 0
        let minLon = coordinates.map(\.longitude).min() ?? 0
        let maxLon = coordinates.map(\.longitude).max() ?? 0
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let spanLat = max(maxLat - minLat, 0.01) * 1.2
        let spanLon = max(maxLon - minLon, 0.01) * 1.2
        
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
    }
    
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $mapRegion,
                showsUserLocation: false,
                annotationItems: getPlanList
            ) { visitPlace in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: visitPlace.placeModel.address.lat,
                        longitude: visitPlace.placeModel.address.lon
                    )
                ) {
                    PlanMapAnnotation(
                        visitPlaceModel: visitPlace
                    )
                    .zIndex(10) // ✅ 어노테이션을 위로
                }
            }
            .onAppear {
                setupMapRegion()
            }
            
            // ✅ overlay로 변경하여 Map 위에 표시
            DashedPath(
                visitPlaces: getPlanList,
                region: mapRegion
            )
            .zIndex(5) // ✅ 점선을 어노테이션보다 아래
            .allowsHitTesting(false) // ✅ 터치 이벤트 차단 안 함
        }
    }
}
