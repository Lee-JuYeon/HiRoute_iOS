//
//  BottomRoundedRectangle.swift
//  HiRoute
//
//  Created by Jupond on 12/19/25.
//
import SwiftUI

struct BottomRoundedRectangle: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
