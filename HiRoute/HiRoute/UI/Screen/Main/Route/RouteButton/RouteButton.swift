//
//  RouteButton.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct RouteButton: View {
    
    private let getOnClick: () -> Void
    init(
        setOnClick: @escaping () -> Void
    ){
        self.getOnClick = setOnClick
    }
    
    @ViewBuilder
    private func image() -> some View {
        Image("img_route_create")
            .resizable() // 이 부분이 핵심!
            .aspectRatio(contentMode: ContentMode.fit)
            .frame(
                maxWidth: .infinity
            )
            .frame(height: 113)
            .clipped()
           
    }
    
    @ViewBuilder
    private func normalText() -> some View {
        VStack(
            alignment : HorizontalAlignment.leading,
            spacing: 4
        ){
            Text("만나기로 한 날, 뭐하지?")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_neutral))
                .fontWeight(.light)
            
            Text("루트짜기")
                .font(.system(size: 24))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.bold)
            
        }
        .padding(EdgeInsets(top: 28, leading: 20, bottom: 29, trailing: 0))
    }
  
    
    var body: some View {
        Button(action: {
            getOnClick()
        }) {
            HStack(
                alignment : VerticalAlignment.center
            ){
                normalText()
                image()
                
            }
        }
        .background(Color.getColour(.background_white))
        .cornerRadius(12)
        .customElevation(.normal)
       
    }
}
