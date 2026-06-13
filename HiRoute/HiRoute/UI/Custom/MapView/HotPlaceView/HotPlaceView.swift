//
//  PlaceHighLightView.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//

import SwiftUI
import MapKit

/// 핫플레이스 폴리곤 오버레이 (레거시 SwiftUI 전용, MKMapView 마이그레이션 후 미사용)
struct HotPlaceView: View {
    private let coordinates: [CLLocationCoordinate2D]
    private let region: MKCoordinateRegion
    private let lineColor: Color
    private let fillColor: Color
    private let lineWidth: CGFloat

    init(coordinates: [CLLocationCoordinate2D], region: MKCoordinateRegion, color: Color = .green) {
        self.coordinates = coordinates
        self.region = region
        self.lineColor = color
        self.fillColor = color.opacity(0.3)
        self.lineWidth = 4
    }

    /// 좌표 변환을 한번만 수행하여 fill + stroke에 재사용
    private var screenPoints: [CGPoint] {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerLat = region.center.latitude
        let centerLon = region.center.longitude
        let latSpan = region.span.latitudeDelta
        let lonSpan = region.span.longitudeDelta

        return coordinates.map { coord in
            let relativeX = (coord.longitude - centerLon) / lonSpan
            let relativeY = (centerLat - coord.latitude) / latSpan
            return CGPoint(
                x: screenWidth * (0.5 + relativeX),
                y: screenHeight * (0.5 + relativeY)
            )
        }
    }

    var body: some View {
        let points = screenPoints
        ZStack {
            closedPath(points: points)
                .fill(fillColor)
            openPath(points: points)
                .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .allowsHitTesting(false)
    }

    // MARK: - Public Methods

    static func drawHotPlace(
        coordinates: [CLLocationCoordinate2D],
        region: MKCoordinateRegion,
        color: Color = .green
    ) -> HotPlaceView {
        return HotPlaceView(coordinates: coordinates, region: region, color: color)
    }

    // MARK: - Private Methods

    private func closedPath(points: [CGPoint]) -> Path {
        Path { path in
            guard points.count > 2, let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() { path.addLine(to: point) }
            path.closeSubpath()
        }
    }

    private func openPath(points: [CGPoint]) -> Path {
        Path { path in
            guard points.count >= 2, let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() { path.addLine(to: point) }
        }
    }
}
