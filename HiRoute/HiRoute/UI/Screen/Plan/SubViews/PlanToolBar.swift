//
//  RootDetailTopBarView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct PlanToolBar : View {
    
    private var getOnClickBack : () -> Void
    private var getOnClickSettings : () -> Void
    init(
        setOnClickBack : @escaping () -> Void,
        setOnClickSettings : @escaping () -> Void
    ){
        self.getOnClickBack = setOnClickBack
        self.getOnClickSettings = setOnClickSettings
    }
    
    var body: some View {
        HStack(){
            
            Image("icon_arrow")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
//                .scaleEffect(x: -1, y: 1) // 수평 반전
                .foregroundColor(Color.getColour(.label_normal))
                .frame(
                    width: 20,
                    height: 20
                )
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                .onTapGesture {
                    getOnClickBack()
                }
            
            Spacer()
            
          
            Image("icon_setting")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 30,
                    height: 30
                )
                .onTapGesture {
                    getOnClickSettings()
                }
        }
        .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
    }
}
