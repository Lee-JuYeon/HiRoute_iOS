//
//  RouteCellType.swift
//  HiRoute
//
//  Created by Jupond on 7/30/25.
//
import SwiftUI

extension View {
    func customElevation(_ level: Elevation) -> some View {
        self.modifier(ElevationModifier(level: level))
    }
}
