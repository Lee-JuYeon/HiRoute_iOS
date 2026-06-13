//
//  ScheduleFullscreenMapView.swift
//  HiRoute
//
//  Created by Jupond on 5/25/26.
//

import SwiftUI

/// PlannerView의 "지도보기" fullScreenCover 컨텐츠.
/// 지도 탭(HomeView)의 본체(`HomeMapContent`)를 재활용 — 검색/칩/추천 리스트 UI 모두 유지.
/// `additionalPlans` 전달로 일정 plans를 번호 마커 + 점선(PlanMapOverlayView)으로 오버레이.
struct ScheduleFullscreenMapView: View {
    let plans: [PlanModel]
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            HomeMapContent(additionalPlans: plans)
            closeButton
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.getColour(.label_strong))
                .frame(width: 36, height: 36)
                .background(Color.getColour(.background_white))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                )
        }
        .padding(.top, 12)
        .padding(.leading, 12)
    }
}
