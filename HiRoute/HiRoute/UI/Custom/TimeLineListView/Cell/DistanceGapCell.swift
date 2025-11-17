//
//  RouteCreateView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//

import SwiftUI


struct DistanceGapCell : View {
    
    private let distance: Double
       
    init(distance: Double) {
        self.distance = distance
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0fm", meters)
        } else {
            return String(format: "%.1fkm", meters / 1000)
        }
    }
    
    var body: some View {
        Text(formatDistance(distance))
            .padding(
                EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
            )
            .font(.system(size: 12))
            .foregroundColor(Color.getColour(.label_normal))
            .background(Color.getColour(.background_white))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.getColour(.line_normal), lineWidth: 1)
            )
            .customElevation(.normal)
            .cornerRadius(4)
            .padding(
                EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            )
          
        
          
    }
}

