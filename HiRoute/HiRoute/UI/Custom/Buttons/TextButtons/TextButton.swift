//
//  EditButton.swift
//  HiRoute
//
//  Created by Jupond on 12/18/25.
//

import SwiftUI

struct TextButton : View {
    
    let text : String
    let textSize : CGFloat
    let textColour : Color
    let callBackClick : () -> Void
    
    var body: some View {
        Text(text)
            .foregroundColor(textColour)
            .font(.system(size: textSize))
            .lineLimit(1)
            .onTapGesture {
                callBackClick()
            }
    }
}
