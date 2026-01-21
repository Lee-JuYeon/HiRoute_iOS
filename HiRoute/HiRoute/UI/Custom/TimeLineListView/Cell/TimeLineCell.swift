//
//  SheetReply.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//

import SwiftUI

struct TimeLineCell : View {
    private var getModel : PlanModel
    private var onClickCell : (PlanModel) -> Void
    private var type: TimeLinePositionType

    init(
        setModel : PlanModel,
        setType : TimeLinePositionType,
        setOnClickCell : @escaping (PlanModel) -> Void
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
            
            // ✅ 장소 제목 표시 (항상 표시)
            Text(getModel.placeModel.title.isEmpty ? "제목 없음" : getModel.placeModel.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.getColour(.label_strong))
                .lineLimit(1)
            
            // ✅ 장소 타입 표시 (항상 표시)
            Text(getModel.placeModel.type.displayText)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Color.getColour(.label_alternative))
                .lineLimit(1)
            
            // ✅ 메모가 있을 때만 메모 표시 (기존 로직 수정)
            if !getModel.memo.isEmpty {
                Text(getModel.memo) // ✅ memo를 표시 (title 아님)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_normal))
                    .lineLimit(2)
            }

            // ✅ 파일이 있을 때만 파일 정보 표시
            if !getModel.files.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 12))
                        .foregroundColor(Color.getColour(.label_alternative))
                    Text("\(getModel.files.count)개 첨부")
                        .font(.system(size: 12))
                        .foregroundColor(Color.getColour(.label_alternative))
                }
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
    
    private func debugPlaceData() -> String {
        let title = getModel.placeModel.title
        let type = getModel.placeModel.type.displayText
        let memo = getModel.memo
        let index = getModel.index
        
        return """
        Debug Info:
        - Index: \(index)
        - Title: '\(title)'
        - Type: '\(type)'
        - Memo: '\(memo)'
        - Files: \(getModel.files.count)개
        """
    }
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            timelineIndicator()
            contentCard()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            // ✅ 디버그: 데이터 확인
            print("TimeLineCell Debug - \(debugPlaceData())")
        }
    }
}
