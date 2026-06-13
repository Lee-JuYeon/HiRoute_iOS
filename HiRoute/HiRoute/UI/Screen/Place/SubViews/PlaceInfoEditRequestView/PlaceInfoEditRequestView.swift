//
//  CustomCalendarView.swift
//  HiRoute
//
//  Created by Jupond on 7/8/25.
//
import SwiftUI

/// "정보 수정 제안" 텍스트 버튼 (탭 시 수정 요청 시트 열림)
///
/// ## Event 패턴 적용 (Prop Drilling 제거)
/// [변경 전] 콜백 파라미터를 상위 뷰로부터 전달받음:
///   - onClickInfoEdit: () -> Void
///   PlaceView → PlaceTopSection → PlaceInfoEditRequestView 순서로 2단계 릴레이.
///
/// [변경 후] @EnvironmentObject로 PlaceVM에 직접 접근.
///   - placeVM.events.editInfo()
///   콜백 파라미터 1개 제거. init 파라미터 완전히 제거됨 (파라미터 없는 뷰).
struct PlaceInfoEditRequestView : View {

    /// PlaceVM에 @EnvironmentObject로 접근하여 정보 수정 시트 이벤트 발생.
    @EnvironmentObject private var placeVM : PlaceVM

    var body: some View {
        HStack(alignment : VerticalAlignment.center, spacing: 4){
            Image("icon_edit")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_alternative))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 20, height: 20)

            Text("정보 수정 제안")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))

            Image("icon_arrow_down")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_alternative))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(270))
        }
        .onTapGesture {
            placeVM.events.editInfo() // [Event] 정보 수정 요청 topSheet 열기
        }
        .padding(
            EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12)
        )
    }
}
