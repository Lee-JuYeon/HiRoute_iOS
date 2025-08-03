//
//  HomePlaceChip.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct LocalisedPlaceChip : View {
    
    private var getHint : String
    private var getText : Binding<String>
    private var getOnClick : () -> Void
    init(
        setHint : String,
        setText : Binding<String>,
        setOnClick : @escaping () -> Void
    ){
        self.getHint = setHint
        self.getText = setText
        self.getOnClick = setOnClick
    }
    
    @ViewBuilder
    private func chip(hint : String, text : Binding<String>, onClick : @escaping () -> Void) -> some View {
        Button {
            onClick()
        } label: {
            let chipVerticalPadding : CGFloat = 8
            let chipHorizontalPadding : CGFloat = 12
            HStack(alignment: VerticalAlignment.center, spacing: 4){
                Text(text.wrappedValue == "" ? hint : text.wrappedValue)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(text.wrappedValue == "" ? Color.getColour(.label_strong) : Color.getColour(.background_white))


                Image("icon_arrow_down")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                    .foregroundColor(text.wrappedValue == "" ? Color.getColour(.label_alternative) : Color.getColour(.background_white))
                    .frame(width: 8, height: 16)

            }
            .padding(.horizontal, chipHorizontalPadding)
            .padding(.vertical, chipVerticalPadding)
            .customElevation(.normal)
            .background(text.wrappedValue == "" ? Color.getColour(.background_white) : Color.getColour(.label_strong))
            .cornerRadius(41)
        }
    }
    
    
    var body: some View {
        chip(hint: getHint, text: getText, onClick: getOnClick)
    }
}
