//
//  FlexibleChipLayout.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

/// 장소 주소 표시 + 주소 복사 버튼
///
/// ## Event 패턴 적용 (Prop Drilling 제거)
/// [변경 전] 콜백 파라미터를 상위 뷰로부터 전달받음:
///   - onClickCopyAddress: (String) -> Void
///   PlaceView → PlaceTopSection → PlaceAddressView 순서로 2단계 릴레이.
///
/// [변경 후] @EnvironmentObject로 PlaceVM에 직접 접근.
///   - placeVM.events.copyAddress(address.fullAddress)
///   콜백 파라미터 1개 제거.
struct PlaceAddressView: View {

    /// 표시할 주소 데이터 (읽기 전용)
    let address : AddressModel

    /// PlaceVM에 @EnvironmentObject로 접근하여 주소 복사 이벤트 발생.
    /// 이 뷰는 @Published를 직접 읽지 않으므로 트리거 변경 시 body 재평가 없음.
    @EnvironmentObject private var placeVM : PlaceVM

    var body: some View {
        HStack(
            alignment: VerticalAlignment.center,
            spacing: 4
        ) {
            Image("icon_pin")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_strong))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 20, height: 20)

            Text(address.fullAddress ?? "")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.bold)
                .lineLimit(1)
                .multilineTextAlignment(.leading)

            Button {
                placeVM.events.copyAddress(address.fullAddress ?? "") // [Event] 클립보드 복사 + 스낵바 표시
            } label: {
                Text("주소 복사")
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.status_positive))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(
            EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12)
        )
    }

}
