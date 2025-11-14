//
//  HomePlaceTitle.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct LocalisedPlaceTitleView : View {
    
    private var title : String
    private var onClickTotalView : () -> Void
    init(
        setTitle : String,
        setOnClickTotalView : @escaping () -> Void
    ){
        self.title = setTitle
        self.onClickTotalView = setOnClickTotalView
    }
    
    private let total : String = "전체보기"
    
    @ViewBuilder
    private func placeTitle() -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.bold)
            
            Spacer()
            
            HStack(alignment:VerticalAlignment.center, spacing: 2){
                Text(total)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .fontWeight(.none)
                
                Image("icon_arrow_right")
                    .frame(width: 7, height: 16)
                    .foregroundColor(Color.getColour(.label_alternative))
            }
            .onTapGesture {
                onClickTotalView()
            }
        }
        .frame(
            maxWidth: .infinity
        )
    }
    
    var body : some View {
        placeTitle()
        
    }
}
