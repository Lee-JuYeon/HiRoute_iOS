//
//  RootDetailTopBarView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct RootDetailTopBarView : View {
    
    private var getOnClickBack : () -> Void
    private var getOnClickShare : () -> Void
    private var getOnClickSettings : () -> Void
    init(
        setOnClickBack : @escaping () -> Void,
        setOnClickShare : @escaping () -> Void,
        setOnClickSettings : @escaping () -> Void
    ){
        self.getOnClickBack = setOnClickBack
        self.getOnClickShare = setOnClickShare
        self.getOnClickSettings = setOnClickSettings
    }
    
    var body: some View {
        HStack(){
            Image("icon_arrow_right")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .scaleEffect(x: -1, y: 1) // 수평 반전
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 24,
                    height: 24
                )
                .onTapGesture {
                    getOnClickBack()
                }
            
            Spacer()
            
            Image("icon_share")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 24,
                    height: 24
                )
                .onTapGesture {
                    getOnClickShare()
                }

            
            Image("icon_setting")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 24,
                    height: 24
                )
                .onTapGesture {
                    getOnClickSettings()
                }
        }
        .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
    }
}
