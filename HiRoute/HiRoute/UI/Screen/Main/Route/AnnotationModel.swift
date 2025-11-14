//
//  AnnotationModel.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//
import SwiftUI
import CoreLocation

struct PlaceModaael: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    let title: String
    let subtitle: String?
    
    var iconName: String {
        switch type {
        case .hospital: return "cross.fill"
        case .store: return "cart.fill"
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .hospital: return .red
        case .store: return .blue
        case .restaurant: return .orange
        case .cafe: return .purple
        }
    }
}
