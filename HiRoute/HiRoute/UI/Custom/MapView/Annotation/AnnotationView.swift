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
        VStack(spacing: 2) {
            Image("icon_map_pin")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(.black)
                .frame(width: 26, height: 32)
                .overlay(
                    Image(systemName: model.iconName)
                        .foregroundColor(.white)
                        .font(.system(size: 11))
                        .offset(y: -3)
                )

            Text(model.title)
                .font(.system(size: 9))
                .foregroundColor(Color.getColour(.label_strong))
                .lineLimit(1)
                .fixedSize()
        }
        .onTapGesture {
            onClick(model)
        }
    }
}
