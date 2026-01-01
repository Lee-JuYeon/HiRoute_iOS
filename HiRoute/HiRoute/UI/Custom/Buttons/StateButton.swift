//
//  RootDetailTopBarView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct StateButton : View {
    
    let iconName: String
    let isEnabled: Bool
    let onTapped: () -> Void
    
    // 상태에 따른 색상
    private var iconColor: ColourType {
        return isEnabled ? .label_strong : .label_alternative
    }
 
    var body: some View {
        Image(iconName)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.getColour(iconColor))
            .onTapGesture {
                // 활성화된 경우에만 클릭 처리
                if isEnabled {
                    onTapped()
                }
            }
    }
}
