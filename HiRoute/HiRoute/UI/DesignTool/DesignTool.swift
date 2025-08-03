//
//  DesignTool.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

extension CGFloat {
    var px: CGFloat { // 피그마 px을 swiftui pt에 반영
        return self / UIScreen.main.scale  // 디바이스 스케일 기준
    }
}

extension Int {
    var px: CGFloat {
        return CGFloat(self) / UIScreen.main.scale
    }
}


extension View {
    func customElevation(_ level: Elevation) -> some View {
        switch level {
        case .normal:
            return self.shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        case .emphasize:
            return self.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        case .strong:
            return self.shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        case .heavy:
            return self.shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}


enum ColourType {
    case background_alternative
    case background_white
    case background_yellow_white
    case fill_alternative
    case fill_normal
    case fill_strong
    case interaction_disable
    case interaction_inactive
    case label_alternative
    case label_assistive
    case label_disable
    case label_neutral
    case label_normal
    case label_strong
    case line_alternative
    case line_neutral
    case line_normal
    case material_dimmer
    case primary_heavy
    case primary_normal
    case primary_strong
    case status_cautionary
    case status_destructive
    case status_positive
}

extension Color {
    static func getColour(_ colourType: ColourType) -> Color {
        return switch colourType {
        case .background_alternative:
            Color("background_alternative")
        case .background_white:
            Color("background_white")
        case .background_yellow_white:
            Color("background_yellow_white")
        case .fill_alternative:
            Color("fill_alternative")
        case .fill_normal:
            Color("fill_normal")
        case .fill_strong:
            Color("fill_strong")
        case .interaction_disable:
            Color("interaction_disable")
        case .interaction_inactive:
            Color("interaction_inactive")
        case .label_alternative:
            Color("label_alternative")
        case .label_assistive:
            Color("label_assistive")
        case .label_disable:
            Color("label_disable")
        case .label_neutral:
            Color("label_neutral")
        case .label_normal:
            Color("label_normal")
        case .label_strong:
            Color("label_strong")
        case .line_alternative:
            Color("line_alternative")
        case .line_neutral:
            Color("line_neutral")
        case .line_normal:
            Color("line_normal")
        case .material_dimmer:
            Color("material_dimmer")
        case .primary_heavy:
            Color("primary_heavy")
        case .primary_normal:
            Color("primary_normal")
        case .primary_strong:
            Color("primary_strong")
        case .status_cautionary:
            Color("status_cautionary")
        case .status_destructive:
            Color("status_destructive")
        case .status_positive:
            Color("status_positive")
        }
    }
    
}
