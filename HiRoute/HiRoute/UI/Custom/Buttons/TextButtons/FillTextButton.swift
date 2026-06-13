//
//  FillTextButton.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//
import SwiftUI

struct FillTextButton : View {

    let text : String
    let onClick : () -> Void

    var body : some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.background_white))
            .lineLimit(1)
            .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
            .frame(maxWidth: .infinity)
            .background(Color.getColour(.label_strong))
            .cornerRadius(8)
            .onTapGesture {
                onClick()
            }
    }
}
