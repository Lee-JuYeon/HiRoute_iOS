//
//  SheetFeedOptions.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//

import SwiftUI
import Foundation
import CoreLocation

struct TimeLineListView : View {
    
    private var getPlaceList : [PlanModel]
    private var onClickCell : (PlanModel) -> Void
    private var getModeType : ModeType
    init(
        setPlanModel : [PlanModel],
        setModeType : ModeType,
        setOnClickCell : @escaping (PlanModel) -> Void
    ){
        self.getPlaceList = setPlanModel
        self.onClickCell = setOnClickCell
        self.getModeType = setModeType
    }
  
    @State private var isShowPlaceSearch : Bool = false
    
    @ViewBuilder
    private func addButton() -> some View {
        Button {
            isShowPlaceSearch = true
            print("리스트 데이터 테스트 : \(getPlaceList)")
        } label: {
            HStack(alignment: .center, spacing: 0){
                Text("방문할 여행지를 추가해볼까요?")
                    .font(.system(size: 20))
                    .foregroundColor(Color.getColour(.background_white))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image("icon_arrow")
                    .renderingMode(.template)
                    .resizable()
                    .scaleEffect(x: -1, y: 1)
                    .foregroundColor(Color.getColour(.background_white))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 16, height: 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color.getColour(.label_strong))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
    }
    
    
    private func calculateDistance(from: PlanModel, to: PlanModel) -> Double {
        let fromLocation = CLLocation(
            latitude: from.placeModel.address.addressLat,
            longitude: from.placeModel.address.addressLon
        )
        let toLocation = CLLocation(
            latitude: to.placeModel.address.addressLat,
            longitude: to.placeModel.address.addressLon
        )
        
        return fromLocation.distance(from: toLocation)
    }
       
    private func getTimelinePositionType(_ index: Int) -> TimeLinePositionType {
        if index == 0 {
            return .FIRST
        } else if index == getPlaceList.count - 1 {
            return .LAST
        } else {
            return .MIDDLE
        }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: HorizontalAlignment.leading, spacing: 0){
                
                if getModeType != .READ {
                    addButton()
                }
              
                ForEach(Array(getPlaceList.enumerated()), id: \.element.uid) { index, visitPlaceModel in
                    TimeLineCell(
                        setModel: visitPlaceModel,
                        setType: getTimelinePositionType(index),
                        setOnClickCell: { clickedVisitPlaceModel in
                            onClickCell(clickedVisitPlaceModel)
                        }
                    )
                    
                    if index < getPlaceList.count - 1 {
                        let nextPlace = getPlaceList[index + 1]
                        let distance = calculateDistance(from: visitPlaceModel, to: nextPlace)
                        
                        DistanceGapCell(distance: distance)
                    }
                }
            }
            .background(Color.clear)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
        }
        .onTapGesture {
            if getModeType != .READ {
                isShowPlaceSearch = true
            }
        }
        .fullScreenCover(isPresented: $isShowPlaceSearch) {
            PlaceSearchView()
        }
    }
    
}

