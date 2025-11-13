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

struct CustomMapView : View {
    
    @Binding var region: MKCoordinateRegion
    let searchResults: [MKMapItem]
    let selectedHotPlaceIds: Set<String>
    
   
    let listHotPlaces: [HotPlaceModel]
    @ViewBuilder
    private func overlayHotPlaces() -> some View {
        ForEach(listHotPlaces, id: \.id) { hotPlace in
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
    
    let listAnnotations: [AnnotationModel]
    let onClickAnnotation: (AnnotationModel) -> Void
    @ViewBuilder
    private func overlayAnnotations() -> some View {
        ForEach(listAnnotations) { annotation in
            AnnotationView(
                model: annotation,
                onClick: onClickAnnotation
            )
            .position(coordinateToScreenPoint(annotation.coordinate))
        }
    }
   
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .overlay(
                   overlayAnnotations()
                )
               
            overlayHotPlaces()
        }
    }
}
