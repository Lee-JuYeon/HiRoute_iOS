//
//  BookmarkSyncResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/28/25.
//
import SwiftUI

/// 장소 상단 섹션 (썸네일, 제목, 별점, 주소, 영업시간, 정보수정, 버튼그룹)
///
/// ## Event 패턴 적용 (Prop Drilling 제거)
/// [변경 전] 5개의 콜백 파라미터를 PlaceView로부터 전달받아 하위 뷰에 릴레이:
///   - onClickCopyAddress → PlaceAddressView
///   - onClickInfoEdit → PlaceInfoEditRequestView
///   - onClickSearchRoute → PlaceButtons
///   - onClickAddPlace → PlaceButtons
///   - onClickBookMark → PlaceButtons
///   PlaceTopSection은 이 콜백들을 사용하지 않고 단순 전달만 수행 (중개자 역할).
///
/// [변경 후] 콜백 파라미터 5개 모두 제거.
///   하위 뷰들이 @EnvironmentObject로 PlaceVM에 직접 접근하므로
///   중간 전달자(PlaceTopSection)가 콜백을 알 필요가 없음.
///   init 파라미터: setPlaceModel 하나만 유지 (데이터 전달).
///
/// [하위 뷰 호출 간소화]
///   - PlaceAddressView(address: model.address)  ← 콜백 제거
///   - PlaceInfoEditRequestView()                 ← 콜백+파라미터 모두 제거
///   - PlaceButtons(setModel: model)              ← 콜백 3개 제거
struct PlaceTopSection : View {

    /// 장소 데이터 모델 (읽기 전용). 하위 뷰에 필요한 데이터를 추출하여 전달.
    private var model : PlaceModel

    @EnvironmentObject private var placeVM: PlaceVM
    @EnvironmentObject private var navigationVM: NavigationVM

    init(
        setPlaceModel : PlaceModel
    ){
        self.model = setPlaceModel
    }

    @ViewBuilder
    private func placeThumbNailImage(imageUrl : String, isAiGenerated: Bool) -> some View {
        // .fill 이미지의 레이아웃 크기가 부모를 확장하지 않도록
        // 고정 높이 컨테이너 위에 overlay로 배치 + clipped
        Color.getColour(.background_alternative)
            .frame(height: 200)
            .overlay(
                ServerImageView(
                    setImageURL: imageUrl
                )
            )
            .clipped()
            .aiWatermark(isAiGenerated: isAiGenerated, size: .normal)
            .onTapGesture {
                var images: [ImageModel] = []
                if let thumb = model.thumbnailImage, !thumb.imageUrl.isEmpty {
                    images.append(thumb)
                }
                images.append(contentsOf: placeVM.currentPlaceImages)

                if images.isEmpty {
                    placeVM.showSnackBarNoImage = true
                } else {
                    placeVM.fullScreenImages = images
                    navigationVM.navigateTo(setDestination: .pictureList)
                }
            }
    }

    @ViewBuilder
    private func placeTitleWithType(title : String, type : String) -> some View{
        HStack(alignment: VerticalAlignment.center, spacing: 4){
            PlaceTitle(title: title)
            PlaceTypeView(type: type)
        }
        .frame(
            alignment: .leading
        )
        .padding(
            EdgeInsets(top: 16, leading: 12, bottom: 4, trailing: 12)
        )
    }

    private let cornerRadius : CGFloat = 20
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0){
            placeThumbNailImage(imageUrl: model.thumbnailImage?.imageUrl ?? "", isAiGenerated: model.thumbnailImage?.isAiGenerated ?? false)
            placeTitleWithType(
                title: model.title,
                type: model.type.displayText
            )

            PlaceStarReviewBookMarkCountView(
                starCount: (model.stars ?? []).count,
                reviewCount: (model.reviews ?? []).count,
                bookMarkCount: (model.bookMarks ?? []).count
            )

            PlaceAddressView(
                address: model.address
            )

            WorkingTimeList(
                setList: model.workingTimes ?? [],
                setPlaceType: model.type
            )

            PlaceInfoEditRequestView()

            PlaceButtons(
                setModel: model
            )
        }
        .background(Color.getColour(.background_white))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(
            EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        )
        .customElevation(.normal)
    }
}
