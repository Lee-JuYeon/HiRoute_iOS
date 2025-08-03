//
//  NeumorphicView.swift
//  HiRoute
//
//  Created by Jupond on 7/3/25.
//

import SwiftUI

struct NeumorphicView<GetView : View> : View {
    
    private var getView : () -> GetView
    private var getWidth : CGFloat
    private var getHeight : CGFloat
    private var getRadius : CGFloat
    init(
        getWidth : CGFloat,
        getHeight : CGFloat,
        getRadius : CGFloat,
        
        @ViewBuilder
        content : @escaping () -> GetView ) {
        self.getView = content
        self.getWidth = getWidth
        self.getHeight = getHeight
        self.getRadius = getRadius
    }
    
    var body : some View {
        VStack(content: getView)
            .background(
                ZStack{
                    Color("LightBackground")
                
                    RoundedRectangle(
                        cornerRadius: 5,
                        style: .continuous
                    ).foregroundColor(Color("LightLightShadow"))
                    .blur(radius: 4)
                    .offset(x: -8, y: -8)
                
                    RoundedRectangle(
                        cornerRadius: getRadius, style: .continuous
                    ).fill(
                        LinearGradient(
                            gradient : Gradient(
                                colors : [
                                    Color("LightDarkShadow"),
                                    Color("LightLightShadow")
                                ]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(2)
                    .blur(radius: 2)
                }
            )
            .clipShape(RoundedRectangle(
                cornerRadius: getRadius,
                style: .continuous
            ))
            .shadow(
                color: Color("LightDarkShadow"),
                radius: 10, x: 5, y: 5)
            .shadow(
                color: Color("LightLightShadow"),
                radius: 10, x: -5, y: -5)
            .padding(.all, 5)
            .frame(
                width: getWidth,
                height: getHeight
            )
    }
}

