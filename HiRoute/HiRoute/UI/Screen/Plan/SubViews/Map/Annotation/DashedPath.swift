//
//  RouteCreateSecondView.swift
//  HiRoute
//
//  Created by Jupond on 7/6/25.
//
import SwiftUI
import MapKit

struct DashedPath: View {
    let visitPlaces: [VisitPlaceModel]
    let region: MKCoordinateRegion
    
    private let annotationRadius: CGFloat = 15
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let coordinates = visitPlaces.sorted(by: { $0.index < $1.index }).map { visitPlace in
                    CLLocationCoordinate2D(
                        latitude: visitPlace.placeModel.address.addressLat,
                        longitude: visitPlace.placeModel.address.addressLon
                    )
                }
                
                let screenPoints = coordinates.map { coordinate in
                    coordinateToScreenPoint(coordinate, geometry: geometry)
                }
                
                // ✅ 각 세그먼트별로 점선 그리기 (중간 어노테이션 피해서)
                drawSegmentedPath(path: &path, points: screenPoints)
            }
            .stroke(
                Color.getColour(.label_strong),
                style: StrokeStyle(
                    lineWidth: 2,
                    dash: [6, 4]
                )
            )
        }
        .allowsHitTesting(false)
    }
    
    // ✅ 세그먼트별로 점선 그리기 (중간 어노테이션들도 피해서)
    private func drawSegmentedPath(path: inout Path, points: [CGPoint]) {
        guard points.count > 1 else { return }
        
        for i in 0..<points.count - 1 {
            let startPoint = points[i]
            let endPoint = points[i + 1]
            
            // 시작점에서 반지름만큼 이동
            let adjustedStart = movePointTowards(
                from: startPoint,
                to: endPoint,
                distance: annotationRadius
            )
            
            // 끝점에서 반지름만큼 뒤로 이동
            let adjustedEnd = movePointTowards(
                from: endPoint,
                to: startPoint,
                distance: annotationRadius
            )
            
            // 조정된 시작점과 끝점으로 선 그리기
            path.move(to: adjustedStart)
            path.addLine(to: adjustedEnd)
        }
    }
    
    // 한 점에서 다른 점 방향으로 특정 거리만큼 이동
    private func movePointTowards(from: CGPoint, to: CGPoint, distance: CGFloat) -> CGPoint {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let length = sqrt(dx * dx + dy * dy)
        
        guard length > distance else { return from } // ✅ 거리가 너무 짧으면 시작점 반환
        
        let unitX = dx / length
        let unitY = dy / length
        
        return CGPoint(
            x: from.x + unitX * distance,
            y: from.y + unitY * distance
        )
    }
    
    private func coordinateToScreenPoint(_ coordinate: CLLocationCoordinate2D, geometry: GeometryProxy) -> CGPoint {
        let centerLat = region.center.latitude
        let centerLon = region.center.longitude
        let latSpan = region.span.latitudeDelta
        let lonSpan = region.span.longitudeDelta
        
        let relativeX = (coordinate.longitude - centerLon) / lonSpan
        let relativeY = (centerLat - coordinate.latitude) / latSpan
        
        let x = geometry.size.width * (0.5 + relativeX)
        let y = geometry.size.height * (0.5 + relativeY)
        
        return CGPoint(x: x, y: y)
    }
}
