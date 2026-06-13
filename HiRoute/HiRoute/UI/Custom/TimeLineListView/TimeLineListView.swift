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
    private var onRequestPlaceSearch : () -> Void
    private var onMove : ((Int, Int) -> Void)?
    @Binding private var isReorderMode : Bool

    init(
        setPlanModel : [PlanModel],
        setModeType : ModeType,
        setIsReorderMode : Binding<Bool> = .constant(false),
        setOnClickCell : @escaping (PlanModel) -> Void,
        setOnRequestPlaceSearch : @escaping () -> Void,
        setOnMove : ((Int, Int) -> Void)? = nil
    ){
        self.getPlaceList = setPlanModel
        self.onClickCell = setOnClickCell
        self.getModeType = setModeType
        self.onRequestPlaceSearch = setOnRequestPlaceSearch
        self.onMove = setOnMove
        self._isReorderMode = setIsReorderMode
    }

    @ViewBuilder
    private func addButton() -> some View {
        Button {
            onRequestPlaceSearch()
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
            latitude: from.placeModel.address.lat,
            longitude: from.placeModel.address.lon
        )
        let toLocation = CLLocation(
            latitude: to.placeModel.address.lat,
            longitude: to.placeModel.address.lon
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

    private func handleOnMove(source: IndexSet, destination: Int) {
        guard let sourceIndex = source.first else { return }
        let adjustedDestination = sourceIndex < destination ? destination - 1 : destination
        onMove?(sourceIndex, adjustedDestination)
    }

    var body: some View {
        VStack(spacing: 0) {
            if getModeType != .READ {
                addButton()
            }

            if isReorderMode {
                // 리오더 모드: List + .onMove
                List {
                    ForEach(getPlaceList, id: \.uid) { visitPlaceModel in
                        Text(visitPlaceModel.placeModel.title.isEmpty ? "제목 없음" : visitPlaceModel.placeModel.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.getColour(.label_strong))
                            .lineLimit(1)
                            .padding(12)
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .listRowBackground(Color.clear)
                    }
                    .onMove(perform: handleOnMove)
                }
                .listStyle(PlainListStyle())
                .environment(\.editMode, .constant(.active))
            } else {
                // 일반 모드: ScrollView + 타임라인
                ScrollView(.vertical) {
                    VStack(alignment: HorizontalAlignment.leading, spacing: 0){
                        ForEach(Array(getPlaceList.enumerated()), id: \.element.uid) { index, visitPlaceModel in
                            TimeLineCell(
                                setModel: visitPlaceModel,
                                setType: getTimelinePositionType(index),
                                setOnClickCell: { clickedVisitPlaceModel in
                                    onClickCell(clickedVisitPlaceModel)
                                }
                            )
                            .onLongPressGesture {
                                if getModeType != .READ {
                                    isReorderMode = true
                                }
                            }

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
                        onRequestPlaceSearch()
                    }
                }
            }
        }
    }

}
