//
//  StrokeTextButton.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//
import SwiftUI

struct StrokeTextButton : View {

    let text : String
    let onClick : () -> Void

    var body : some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.label_strong))
            .lineLimit(1)
            .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
            .frame(maxWidth: .infinity)
            .background(Color.getColour(.background_white))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )
            .onTapGesture {
                onClick()
            }
    }
}
