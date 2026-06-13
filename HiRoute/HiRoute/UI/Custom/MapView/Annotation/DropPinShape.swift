//
//  DropPinShape.swift
//  HiRoute
//
//  Created by Jupond on 3/6/26.
//

import SwiftUI

/// 맵 핀 모양 (상단 원형 + 하단 얇은 기둥 꼭지)
struct DropPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let r = w / 2
        let center = CGPoint(x: w / 2, y: r)
        let tip = CGPoint(x: w / 2, y: h)

        // 기둥 반폭 (~6pt)
        let stemHalf: CGFloat = 3.0

        // 기둥이 원과 만나는 각도 (좁은 틈)
        let stemAngle = asin(stemHalf / r) // 라디안
        let stemAngleDeg = stemAngle * 180 / .pi
        let startDeg = 90.0 - Double(stemAngleDeg) // 우측 출발점
        let endDeg = 90.0 + Double(stemAngleDeg)   // 좌측 도착점

        var path = Path()

        // 원호: 우측하단 → 위쪽 경유 → 좌측하단 (거의 전체 원)
        path.addArc(
            center: center,
            radius: r,
            startAngle: .degrees(startDeg),
            endAngle: .degrees(endDeg),
            clockwise: true
        )

        // 좌측하단 → 꼭지점 (직선에 가까운 얇은 기둥)
        path.addLine(to: tip)

        // 꼭지점 → 우측하단 (직선)
        path.addLine(
            to: CGPoint(
                x: center.x + r * cos(CGFloat(startDeg) * .pi / 180),
                y: center.y + r * sin(CGFloat(startDeg) * .pi / 180)
            )
        )

        path.closeSubpath()
        return path
    }
}
