//
//  HotPlaceSection.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//
import SwiftUI

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
