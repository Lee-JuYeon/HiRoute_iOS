//
//  HomePlaceChips.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct LocalisedPlaceChips : View {
    
    @State private var choosePlaceChipText : String = ""
    @State private var isSheetPlaceChip : Bool = false
    
    @State private var chooseThemeChipText : String = ""
    @State private var isSheetThemeChip : Bool = false
    
    @State private var chooseMostLikedChipText : String = ""
    @State private var isSheetMostLikedChip : Bool = false
    
    @ViewBuilder
    private func chipsView() -> some View {
        let verticalSpacing : CGFloat = 12
        let horizontalSpacing : CGFloat = 8
        VStack(alignment:HorizontalAlignment.leading, spacing: verticalSpacing){
            HStack(alignment: VerticalAlignment.center, spacing: horizontalSpacing){
                LocalisedPlaceChip(setHint: "장소", setText: $choosePlaceChipText, setOnClick: {
                    isSheetPlaceChip.toggle()
                    choosePlaceChipText = "청량리/회기/장한평"
                })
               
                Text("에 있는")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                
                LocalisedPlaceChip(setHint: "전체", setText: $chooseThemeChipText, setOnClick: {
                    isSheetThemeChip.toggle()
                })
                
                Text("플레이스를")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
            }
           
            HStack(alignment: VerticalAlignment.center, spacing: 8) {
                LocalisedPlaceChip(setHint: "추천순", setText: $chooseMostLikedChipText, setOnClick: {
                    isSheetMostLikedChip.toggle()
                })
                
                Text("으로 알려드릴게요")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
            }
        }
    }
    
    var body: some View {
        chipsView()
    }
}
