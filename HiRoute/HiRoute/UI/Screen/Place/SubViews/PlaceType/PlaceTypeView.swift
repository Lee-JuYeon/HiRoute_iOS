//
//  ScheduleGachaScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct PlaceTypeView: View {
   
    let type : String
    
    var body: some View {
        Text(type)
            .font(.system(size: 14))
            .foregroundColor(Color.getColour(.label_alternative))
            .fontWeight(.light)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
    }
}
