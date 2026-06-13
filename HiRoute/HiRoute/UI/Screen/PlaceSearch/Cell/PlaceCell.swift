//
//  ScheduleListEditButton.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//
import SwiftUI

struct PlaceCell : View {
    
    private var getPlaceModel : PlaceModel
    private var getCellType : PlaceCellType
    private var getIsAlreadyAdded : Bool
    private var getOnClickAdd : () -> Void
    private var getOnClickCell : (PlaceModel) -> Void
    init(
        setPlaceModel : PlaceModel,
        setPlaceCellType : PlaceCellType,
        setIsAlreadyAdded : Bool = false,
        onClickAdd : @escaping () -> Void,
        onClickCell : @escaping (PlaceModel) -> Void
    ){
        self.getPlaceModel = setPlaceModel
        self.getCellType = setPlaceCellType
        self.getIsAlreadyAdded = setIsAlreadyAdded
        self.getOnClickAdd = onClickAdd
        self.getOnClickCell = onClickCell
    }
   
    var body: some View {
        HStack(alignment : VerticalAlignment.center){
            ServerImageView(
                setImageURL: getPlaceModel.thumbnailImage?.imageUrl ?? ""
            )
            .background(Color.getColour(.background_alternative))
            .frame(
                width: 72,
                height: 72
            )
            .clipShape(RoundedRectangle(cornerRadius: 9.6))
            .clipped()
            .aiWatermark(isAiGenerated: getPlaceModel.thumbnailImage?.isAiGenerated ?? false, size: .thumbnail)
            
            
            VStack(alignment: HorizontalAlignment.leading){
                Text(getPlaceModel.type.displayText)
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.label_alternative))
                
                Text(getPlaceModel.title)
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
            
            Text(getIsAlreadyAdded ? "추가됨" : "추가")
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .font(.system(size: 14))
                .foregroundColor(getIsAlreadyAdded ? Color.getColour(.label_alternative) : Color.getColour(.label_strong))
                .background(getIsAlreadyAdded ? Color.getColour(.label_disable) : Color.getColour(.background_white))
                .customElevation(.heavy)
                .clipShape(RoundedRectangle(cornerRadius: 41))
                .clipped()
                .onTapGesture {
                    getOnClickAdd()
                }
                
        }
        .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .onTapGesture {
            getOnClickCell(getPlaceModel)
        }
    }
}
