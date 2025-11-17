//
//  SheetReply.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//

import SwiftUI

struct TimeLineCell : View {
    private var getModel : VisitPlaceModel
    private var onClickCell : (VisitPlaceModel) -> Void
    private var type: TimeLinePositionType

    init(
        setModel : VisitPlaceModel,
        setType : TimeLinePositionType,
        setOnClickCell : @escaping (VisitPlaceModel) -> Void
    ){
        self.getModel = setModel
        self.onClickCell = setOnClickCell
        self.type = setType
    }
  
    @ViewBuilder
    private func timelineIndicator() -> some View {
        VStack(spacing: 0) {
            //위쪽 점선 관리
            VStack(spacing: 0) {
                switch type {
                case .FIRST:
                    Color.clear
                case .MIDDLE, .LAST:
                    dashedLine()
                }
            }
            .frame(maxHeight: .infinity)

            
            // 동그란 인덱스
            Text("\(getModel.index)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.getColour(.background_white))
                .frame(width: 24, height: 24)
                .background(Color.getColour(.label_strong))
                .clipShape(Circle())
            
            // 아래쪽 점선 관리
            VStack(spacing: 0) {
                switch type {
                case .LAST:
                    Color.clear
                case .FIRST, .MIDDLE:
                    dashedLine()
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 50)
    }
    
    @ViewBuilder
    private func dashedLine() -> some View {
        Rectangle()
            .fill(Color.getColour(.line_normal))
            .frame(width: 2)
            .mask(
                VStack(spacing: 2) {
                    ForEach(0..<20, id: \.self) { _ in
                        Rectangle()
                            .frame(height: 3)
                    }
                }
            )
    }
       
    @ViewBuilder
    private func contentCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getModel.placeModel.type.displayText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.getColour(.label_alternative))
                .lineLimit(1)
            
            if !getModel.memo.isEmpty {
                Text(getModel.placeModel.title)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                    .lineLimit(2)
            }

            if !getModel.files.isEmpty {
                Text(getModel.memo)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_neutral))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.getColour(.background_white))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.getColour(.line_normal), lineWidth: 1)
        )
        .customElevation(Elevation.normal)
        .cornerRadius(12)
        .onTapGesture {
            onClickCell(getModel)
        }
    }
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            timelineIndicator()
            contentCard()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
