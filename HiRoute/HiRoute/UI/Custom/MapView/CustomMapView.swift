//
//  CustomMapView.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import SwiftUI
import MapKit

struct CustomMapView: View {

    @Binding var region: MKCoordinateRegion
    let searchResults: [MKMapItem]
    let selectedHotPlaceIds: Set<String>
    let listHotPlaces: [HotPlaceModel]
    let geoObjects: [GeoObjectModel]
    let listAnnotations: [PlaceModel]
    let onClickAnnotation: (PlaceModel) -> Void

    /// 줌 레벨에 따른 반경 원 크기 (pt)
    /// 줌 인(latitudeDelta 작음) → 원 커짐, 줌 아웃(latitudeDelta 큼) → 원 작아짐
    private var radiusCircleSize: CGFloat {
        let delta = region.span.latitudeDelta
        // 화면 대비 반경 비율: 쿼리 반경(delta/2)이 뷰포트(delta) 대비 50%
        // 줌 인할수록 원이 화면을 더 많이 차지하도록 스케일링
        // 기본 200pt 기준, delta 0.01일 때 200pt → delta 변화에 반비례
        let baseSize: CGFloat = 200
        let baseDelta: CGFloat = 0.01
        let size = baseSize * CGFloat(baseDelta / delta)
        return min(max(size, 80), 350) // 80~350pt 범위 제한
    }

    var body: some View {
        ZStack {
            NativeMapView(
                region: $region,
                showsUserLocation: true,
                annotations: listAnnotations,
                hotPlaces: listHotPlaces,
                geoObjects: geoObjects,
                selectedHotPlaceIds: selectedHotPlaceIds,
                onAnnotationTap: onClickAnnotation
            )

            // 뷰포트 반경 시각화 (화면 중앙 고정 HUD, 줌 연동)
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Circle().fill(Color.gray.opacity(0.07)))
                .frame(width: radiusCircleSize, height: radiusCircleSize)
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.2), value: radiusCircleSize)
        }
    }
}
