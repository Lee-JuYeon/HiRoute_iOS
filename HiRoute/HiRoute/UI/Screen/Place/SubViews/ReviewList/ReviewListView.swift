//
//  ReviewListView.swift
//  HiRoute
//
//  Created by Jupond on 11/20/25.
//

import SwiftUI

/// 리뷰 리스트 뷰 (리뷰 작성 버튼 + 필터 + 리뷰 목록)
///
/// ## Event 패턴 적용 (Prop Drilling 제거)
/// [변경 전] 2개의 콜백 파라미터를 상위 뷰로부터 전달받음:
///   - callBackClickCell: (ReviewModel) -> Void  (리뷰 셀 클릭)
///   - callBackWriteReview: () -> Void            (리뷰 작성 버튼 클릭)
///   PlaceView → PlaceBottomSection → ReviewListView 순서로 2단계 릴레이.
///
/// [변경 후] @EnvironmentObject로 PlaceVM에 직접 접근.
///   - placeVM.events.writeReview()
///   콜백 파라미터 2개 제거.
///   init 파라미터: setPlaceModel, setNationalityType만 유지 (데이터 전달).
struct ReviewListView : View {

    /// 리뷰를 표시할 장소 모델 (읽기 전용)
    private var model : PlaceModel
    /// 사용자 국적 (리뷰 표시 언어/형식 결정용)
    private var nationalityType : NationalityType

    /// PlaceVM에 @EnvironmentObject로 접근.
    /// 리뷰 작성 버튼 클릭 시 placeVM.events.writeReview() 호출.
    @EnvironmentObject private var placeVM : PlaceVM
    @EnvironmentObject private var navigationVM : NavigationVM

    init(
        setPlaceModel : PlaceModel,
        setNationalityType : NationalityType
    ){
        self.model = setPlaceModel
        self.nationalityType = setNationalityType
    }

    @ViewBuilder
    private func reviewWriteButton() -> some View {
        Button {
            navigationVM.navigateTo(setDestination: .reviewWrite)
        } label: {
            HStack(alignment: .center, spacing: 0){
                VStack(alignment: HorizontalAlignment.leading, spacing: 4, content: {
                    Text("\(model.title) 다녀오셨나요?")
                        .font(.system(size: 18))
                        .foregroundColor(Color.getColour(.background_white))
                        .fontWeight(.light)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)

                    HStack(alignment: .center, spacing: 4){
                        Text("리뷰 작성하기")
                            .font(.system(size: 16))
                            .foregroundColor(Color.getColour(.background_white))
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)

                        Image("icon_arrow")
                            .renderingMode(.template)
                            .resizable()
                            .scaleEffect(x: -1, y: 1) // 수평반전
                            .foregroundColor(Color.getColour(.background_white))
                            .aspectRatio(contentMode: ContentMode.fit)
                            .frame(width: 12, height: 12)

                    }
                })

                Spacer()

                Image("img_review_write")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_alternative))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 60, height: 40)

            }


        }
        .frame(
            maxWidth: .infinity
        )
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color.getColour(.label_strong))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
    }

    /// 현재 필터 타입에 따라 정렬된 리뷰 목록
    /// placeVM.placeReviews (API에서 별도 로드) 사용
    private var sortedReviews: [ReviewModel] {
        switch reviewListFilterType {
        case .new:
            return placeVM.placeReviews.sorted { ($0.visitDate ?? "") > ($1.visitDate ?? "") }
        case .recommend:
            return placeVM.placeReviews.sorted { ($0.usefulList ?? []).count > ($1.usefulList ?? []).count }
        case .manyStar:
            return placeVM.placeReviews.sorted { $0.rating > $1.rating }
        case .littleStar:
            return placeVM.placeReviews.sorted { $0.rating < $1.rating }
        }
    }

    @State private var reviewListFilterType : ReviewListFilterType = .new
    @State private var expandFilterSheet : Bool = false
    @ViewBuilder
    private func listFilterView() -> some View {
        HStack(alignment: VerticalAlignment.center, spacing: 4){
            Text("\(reviewListFilterType.displayText)")
                .font(.system(size: 18))
                .foregroundColor(Color.getColour(.label_neutral))
                .fontWeight(.bold)
                .lineLimit(1)
                .multilineTextAlignment(.leading)

            Image("icon_arrow")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_neutral))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(270))
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .onTapGesture {
            expandFilterSheet = true
        }
    }

    var body: some View {
        ScrollView(Axis.Set.vertical){
            LazyVStack(alignment: .leading, spacing: 0){
                reviewWriteButton()
                listFilterView()

                ForEach(sortedReviews, id: \.reviewUid){ reviewModel in
                    ReviewCell(
                        setModel : reviewModel,
                        setNationalityType: nationalityType,
                        onCallBackOption : { reviewUid in

                        },
                        onCallBackUseful : { userUid in

                        }
                    )
                    .onAppear {
                        if reviewModel.reviewUid == sortedReviews.last?.reviewUid {
                            placeVM.loadMoreReviews(placeUid: model.uid)
                        }
                    }
                }

                if placeVM.isLoadingMoreReviews {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .bottomSheet(isOpen: $expandFilterSheet) {
            SheetReviewListFilter { filterType in
                reviewListFilterType = filterType
                expandFilterSheet = false
            }
        }
    }
}
