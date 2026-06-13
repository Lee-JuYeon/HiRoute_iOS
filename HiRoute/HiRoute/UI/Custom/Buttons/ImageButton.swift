//
//  BackButton.swift
//  HiRoute
//
//  Created by Jupond on 12/18/25.
//

import SwiftUI

struct ImageButton : View {
    
    let imageUrl : String
    let imageSize : CGFloat
    let callBackClick : () -> Void
    
    var body: some View {
        Image(imageUrl)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: ContentMode.fit)
            .foregroundColor(Color.getColour(.label_normal))
            .frame(
                width: imageSize,
                height: imageSize
            )
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .onTapGesture {
                callBackClick()
            }
    }
}
