//
//  PlaceHighLightCell.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import MapKit
import SwiftUI

struct HotPlaceModel {
    let id: String
    let name: String
    let emoji: String
    let coordinates: [CLLocationCoordinate2D]
    let color: Color
    let description: String
    
    init(id: String, name: String, emoji: String, coordinates: [CLLocationCoordinate2D], color: Color = .green, description: String = "") {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.coordinates = coordinates
        self.color = color
        self.description = description
    }
}
