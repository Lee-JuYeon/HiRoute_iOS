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
    
    private var getPlaceList : [VisitPlaceModel]
    private var onClickCell : (VisitPlaceModel) -> Void
    init(
        setPlanModel : [VisitPlaceModel],
        setOnClickCell : @escaping (VisitPlaceModel) -> Void
    ){
        self.getPlaceList = setPlanModel
        self.onClickCell = setOnClickCell
    }
  
    
    private func calculateDistance(from: VisitPlaceModel, to: VisitPlaceModel) -> Double {
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
                ForEach(Array(getPlaceList.enumerated()), id: \.element.uid) { index, visitPlaceModel in
                    TimeLineCell(
                        setModel: visitPlaceModel,
                        setType: getTimelinePositionType(index),
                        setOnClickCell: { clickedVisitPlaceModel in
                            print("클릭된거 : \(clickedVisitPlaceModel)")
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
    }
    
}

