//
//  ChipView.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

struct PlaceTitle: View {
    
    let title : String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.bold)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
    }
}
