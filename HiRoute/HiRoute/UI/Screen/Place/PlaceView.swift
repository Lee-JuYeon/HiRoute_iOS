//
//  BookmarkChange.swift
//  HiRoute
//
//  Created by Jupond on 7/29/25.
//
import SwiftUI

struct PlaceView : View {
    
    private var getPlaceModel : PlaceModel
    private var getNationalityType : NationalityType
    @Environment(\.presentationMode) var presentationMode
    init(
        setPlaceModel : PlaceModel,
        setNationalityType : NationalityType
    ){
        self.getPlaceModel = setPlaceModel
        self.getNationalityType = setNationalityType
    }
    
    @ViewBuilder
    private func backButton() -> some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image("icon_arrow")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .foregroundColor(Color.getColour(.label_normal))
                .frame(width: 20, height: 20)
        }
        .frame(width: 44, height: 44) // ✅ 터치 영역 확장
        .contentShape(Rectangle()) // ✅ 전체 영역을 터치 가능하게
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
    
    var body: some View {
        VStack {
            HStack(alignment:.center, spacing: 0) {
                backButton()
                Spacer()
            }
            
            
            ScrollView(.vertical) {
                VStack(alignment: HorizontalAlignment.leading, spacing: 0){
                    
                    
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
                        setNationalityType: getNationalityType,
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
}
