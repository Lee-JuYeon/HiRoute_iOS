//
//  StoreCell.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI

struct PlanMapAnnotation : View {
    let visitPlaceModel: VisitPlaceModel
    let onClick: (VisitPlaceModel) -> Void
    
    var body: some View {
        Button(action: {
            onClick(visitPlaceModel)
        }) {
            VStack(spacing: 0) {
                // 물방울 모양 배경 + 인덱스 텍스트
                ZStack {
                    // 물방울 모양 (원 + 삼각형)
                    VStack(spacing: 0) {
                        Circle()
                            .fill(Color.getColour(.label_strong))
                            .frame(width: 30, height: 30)
                            .customElevation(.normal)
                        
                        // 아래쪽 뾰족한 부분
                        Triangle()
                            .fill(Color.getColour(.label_strong))
                            .frame(width: 8, height: 6)
                            .offset(y: -1)
                    }
                    
                    // 인덱스 텍스트
                    Text("\(visitPlaceModel.index)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.getColour(.background_white))
                        .offset(y: -3) // 삼각형 때문에 약간 위로 조정
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
