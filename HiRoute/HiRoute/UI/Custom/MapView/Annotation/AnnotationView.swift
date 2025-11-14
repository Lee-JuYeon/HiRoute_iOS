//
//  SearchVM.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI
import MapKit

struct AnnotationView: View {
    let model: PlaceModel
    let onClick: (PlaceModel) -> Void
    
    var body: some View {
        Button(action: {
            onClick(model)
        }) {
            VStack(spacing: 2) {
                Image(systemName: model.iconName)
                    .foregroundColor(model.iconColor)
                    .font(.title2)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                            .shadow(radius: 2)
                    )
                
                Text(model.title)
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.horizontal, 4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
