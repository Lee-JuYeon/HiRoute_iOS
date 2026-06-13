//
//  PlanMapOverlayView.swift
//  HiRoute
//
//  Created by Jupond on 5/25/26.
//

import SwiftUI
import MapKit

/// CustomMapView 위에 일정 plans의 번호 마커(`PlanMapAnnotation`) + 점선(`DashedPath`)을 오버레이.
/// region은 호출부(HomeMapContent)에서 CustomMapView와 같은 binding을 공유.
///
/// 한계: `NativeMapView`가 `regionDidChangeAnimated`에서만 region binding을 업데이트하므로
/// 연속 pan/zoom 중에는 마커 위치가 약간 lag될 수 있음. 제스처 종료 후 정확히 정렬.
struct PlanMapOverlayView: View {
    let plans: [PlanModel]
    let region: MKCoordinateRegion

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 점선 (마커보다 아래)
                DashedPath(visitPlaces: plans, region: region)
                    .zIndex(5)

                // 번호 마커 (점선 위)
                ForEach(plans) { plan in
                    let pos = coordinateToScreenPoint(
                        lat: plan.placeModel.address.lat,
                        lon: plan.placeModel.address.lon,
                        geometry: geometry
                    )
                    PlanMapAnnotation(visitPlaceModel: plan)
                        .position(x: pos.x, y: pos.y)
                        .zIndex(10)
                }
            }
        }
    }

    private func coordinateToScreenPoint(lat: Double, lon: Double, geometry: GeometryProxy) -> CGPoint {
        let centerLat = region.center.latitude
        let centerLon = region.center.longitude
        let latSpan = region.span.latitudeDelta
        let lonSpan = region.span.longitudeDelta

        let relativeX = (lon - centerLon) / lonSpan
        let relativeY = (centerLat - lat) / latSpan

        let x = geometry.size.width * (0.5 + relativeX)
        let y = geometry.size.height * (0.5 + relativeY)

        return CGPoint(x: x, y: y)
    }
}
