//
//  RouteSplashView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI

/// 장소 하단 버튼 그룹 (길찾기, 일정추가, 북마크)
///
/// ## Event 패턴 적용 (Prop Drilling 제거)
/// [변경 전] 3개의 콜백 파라미터를 상위 뷰로부터 전달받음:
///   - onClickSearchRoute: () -> Void
///   - onClickAddPlace: () -> Void
///   - onClickBookMark: (PlaceModel) -> Void
///   이 콜백들은 PlaceView → PlaceTopSection → PlaceButtons 순서로
///   2단계 릴레이되었으나, 중간 뷰(PlaceTopSection)는 단순 전달 역할만 수행.
///
/// [변경 후] @EnvironmentObject로 PlaceVM에 직접 접근.
///   - placeVM.events.searchRoute()
///   - placeVM.events.addPlace()
///   - placeVM.events.toggleBookMark(setModel)
///   콜백 파라미터 3개 제거. 중간 뷰 수정 불필요.
struct PlaceButtons : View {

    /// 북마크 토글 시 전달할 장소 데이터 (읽기 전용)
    let setModel : PlaceModel

    /// PlaceVM에 @EnvironmentObject로 접근하여 이벤트 발생.
    /// PlaceView 상위에서 .environmentObject(placeVM)으로 주입됨.
    /// 이 뷰는 placeVM.events의 메서드만 호출하고 @Published를 읽지 않으므로,
    /// 트리거 변경 시 이 뷰의 body는 재평가되지 않음 (성능 안전).
    @EnvironmentObject private var placeVM : PlaceVM
    @EnvironmentObject private var navigationVM : NavigationVM

    @ViewBuilder
    private func navigationButton() -> some View {
        Button {
            navigationVM.navigateTo(setDestination: .searchRoute)
        } label: {
            VStack(alignment: HorizontalAlignment.center, spacing: 8) {
                Image("icon_pin")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 24, height: 24)

                Text("길찾기")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
            }
        }
        .frame(maxWidth: .infinity) // 버튼 너비를 최대한 늘림
    }

    @ViewBuilder
    private func addPlaceButton() -> some View {
        Button {
            placeVM.events.addPlace() // [Event] 일정추가 바텀시트 열기
        } label: {
            VStack(alignment: HorizontalAlignment.center, spacing: 8) {
                Image("icon_pin")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 24, height: 24)

                Text("일정에 추가")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))

            }
        }
        .frame(maxWidth: .infinity) // 버튼 너비를 최대한 늘림
    }

    /// 현재 유저가 이 장소를 북마크했는지 확인
    /// placeVM.myBookmarkedPlaces(CoreData 기반)에서 확인하여 실시간 상태 반영
    private var isBookmarked: Bool {
        placeVM.myBookmarkedPlaces.contains { $0.uid == setModel.uid }
    }

    @ViewBuilder
    private func bookMarkButton() -> some View {
        Button {
            placeVM.events.toggleBookMark(setModel) // [Event] 북마크 토글
        } label: {
            VStack(alignment: HorizontalAlignment.center, spacing: 8) {
                Image(isBookmarked ? "icon_bookmark_on" : "icon_bookmark_off")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 24, height: 24)

                Text("북마크")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))

            }
        }
        .frame(maxWidth: .infinity) // 버튼 너비를 최대한 늘림
    }

    var body: some View {
        VStack(alignment: HorizontalAlignment.center, spacing: 0){
            Rectangle()
                .fill(Color.getColour(.line_alternative))
                .frame(
                    maxWidth: .infinity,
                    idealHeight: 1
                )

            HStack(alignment: VerticalAlignment.center, spacing: 0){
                navigationButton()
                addPlaceButton()
                bookMarkButton()
            }
            .padding(
                EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            )
            .frame(maxWidth: .infinity)
        }
    }
}
