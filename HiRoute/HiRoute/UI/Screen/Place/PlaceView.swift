//
//  BookmarkChange.swift
//  HiRoute
//
//  Created by Jupond on 7/29/25.
//
import SwiftUI

struct PlaceView : View {
    
    private var getPlaceModel : PlaceModel
    @Binding private var isShow : Bool
    init(
        setPlaceModel : PlaceModel,
        isPresented : Binding<Bool>
    ){
        self.getPlaceModel = setPlaceModel
        self._isShow = isPresented
    }
    
    @ViewBuilder
    private func backButton() -> some View {
        return Image("icon_arrow_right")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: ContentMode.fit)
            .scaleEffect(x: -1, y: 1) // 수평 반전
            .foregroundColor(Color.getColour(.label_strong))
            .frame(
                width: 40,
                height: 40
            )
            .onTapGesture {
                isShow = false
            }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: HorizontalAlignment.leading, spacing: 0){
                HStack(alignment: VerticalAlignment.center, spacing: 0){
                    backButton()
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                
                PlaceTopSection(
                    setPlaceModel: getPlaceModel,
                    onCallBackEditInfo: { placeUID in
                        //정보 변경 제안하기 뷰
                    },
                    onCallBackCopyAddress: { addressModel in
                        // 주소 복사 기능
                    },
                    onCallBackBookMark: { bookMarkedUID in
                        // 북마크 추가/삭제
                    },
                    onCallBackNavigate: { addressModel in
                        // 길찾기
                    },
                    onCallBackAddPlace: { placeModel in
                        // 일정에 place추가
                    }
                )
                
                PlaceBottomSection(
                    setPlaceModel: getPlaceModel,
                    onClickReviewCell: { reviewModel in
                        // 리뷰 셀 클릭이벤트
                    },
                    onCallBackWriteReview: { placeUID in
                        // 리뷰 작성뷰로 이동
                    }
                )
            }
        }
        .background(Color.getColour(.background_yellow_white))
    }
}
