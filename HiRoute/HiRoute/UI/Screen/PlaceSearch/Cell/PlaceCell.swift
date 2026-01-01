//
//  ScheduleListEditButton.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//
import SwiftUI

struct PlaceCell : View {
    
    private var getImageURL : String
    private var getTheme : String
    private var getPlaceTitle : String
    private var getCellType : PlaceCellType
    private var getCallBackClick : () -> Void
    init(
        setImageURL : String,
        setTheme : String,
        setTitle : String,
        setPlaceCellType : PlaceCellType,
        callBackClick : @escaping () -> Void
    ){
        self.getImageURL = setImageURL
        self.getTheme = setTheme
        self.getPlaceTitle = setTitle
        self.getCellType = setPlaceCellType
        self.getCallBackClick = callBackClick
    }
   
    var body: some View {
        HStack(alignment : VerticalAlignment.center){
            ServerImageView(
                setImageURL: getImageURL
            )
            .background(Color.getColour(.background_alternative))
            .frame(
                width: 72,
                height: 72
            )
            .clipShape(RoundedRectangle(cornerRadius: 9.6))
            .clipped()
            
            
            VStack(alignment: HorizontalAlignment.leading){
                Text(getTheme)
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.label_alternative))
                
                Text(getPlaceTitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                
                if getCellType == .HOT {
                    Text("HOT")
                        .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                        .font(.system(size: 10))
                        .foregroundColor(Color.getColour(.status_destructive))
                        .background(
                            Color.getColour(.status_destructive).opacity(0.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .clipped()
                    
                }
            }
            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))

            Spacer()
            
            Text("추가")
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_strong))
                .background(Color.getColour(.background_white))
                .customElevation(.heavy)
                .clipShape(RoundedRectangle(cornerRadius: 41))
                .clipped()
                .onTapGesture {
                    getCallBackClick()
                }
                
        }
        .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}
