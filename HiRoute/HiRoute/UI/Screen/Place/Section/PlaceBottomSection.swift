//
//  UserModel.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import SwiftUI

struct PlaceBottomSection : View {
    
    private var getVisitPlaceModel : VisitPlaceModel
    private var getNationalityType : NationalityType
    private var getPlaceModeType : PlaceModeType
    private var getOnClickReviewCell : (ReviewModel) -> Void
    private var getOnClickWriteReview : (String) -> Void
    init(
        setVisitPlaceModel : VisitPlaceModel,
        setNationalityType : NationalityType,
        setPlaceModeType : PlaceModeType,
        onClickReviewCell : @escaping (ReviewModel) -> Void,
        onCallBackWriteReview : @escaping (String) -> Void
    ){
        self.getVisitPlaceModel = setVisitPlaceModel
        self.getNationalityType = setNationalityType
        self.getOnClickReviewCell = onClickReviewCell
        self.getOnClickWriteReview = onCallBackWriteReview
        self.getPlaceModeType = setPlaceModeType
    }
    
  
    @EnvironmentObject private var scheduleVM : ScheduleViewModel
    @State private var selectedTabIndex = 0
    
    private func tabTitles() -> [String] {
        switch getPlaceModeType {
        case .MY :
            return ["메모", "리뷰"]
        case .OTHER :
            return ["리뷰"]
        }
    }

    
    @ViewBuilder
    private func tabHeader() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(tabTitles().enumerated()), id: \.offset) { index, title in
                VStack(spacing: 0) {
                    // 탭 텍스트
                    Text(title)
                        .font(.system(size: 14, weight: selectedTabIndex == index ? .bold : .regular))
                        .foregroundColor(selectedTabIndex == index ? Color.getColour(.label_strong) : Color.getColour(.label_alternative))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            selectedTabIndex = index
                        }
                    
                    // 인디케이터 밑줄
                    Rectangle()
                        .fill(selectedTabIndex == index ? Color.getColour(.label_strong) : Color.getColour(.line_alternative))
                        .frame(height: 2)
                }
            }
        }
        .background(Color.clear)
    }
    
    @ViewBuilder
    private func tabContent() -> some View {
        switch getPlaceModeType {
        case .MY :
            switch selectedTabIndex {
            case 0:
                MultiLineMemoView(
                    setHint: "메모를 입력해보세요",
                    setText: scheduleVM.visitPlaceMemoBinding,
                    setModeType: ModeType.READ
                )
                ReviewListView(
                    setPlaceModel: getVisitPlaceModel.placeModel,
                    setNationalityType: getNationalityType,
                    setOnClickCell: { clickedModel in
                        // 리뷰 셀 클릭이벤트
                        getOnClickReviewCell(clickedModel)
                    },
                    setOnClickWriteReview: {
                        // 리뷰 작성뷰로 이동
                        getOnClickWriteReview(getVisitPlaceModel.placeModel.uid)
                        
                    }
                )
            case 1:
                ReviewListView(
                    setPlaceModel: getVisitPlaceModel.placeModel,
                    setNationalityType: getNationalityType,
                    setOnClickCell: { clickedModel in
                        // 리뷰 셀 클릭이벤트
                        getOnClickReviewCell(clickedModel)
                    },
                    setOnClickWriteReview: {
                        // 리뷰 작성뷰로 이동
                        getOnClickWriteReview(getVisitPlaceModel.placeModel.uid)
                        
                    }
                )
            default:
                ReviewListView(
                    setPlaceModel: getVisitPlaceModel.placeModel,
                    setNationalityType: getNationalityType,
                    setOnClickCell: { clickedModel in
                        // 리뷰 셀 클릭이벤트
                        getOnClickReviewCell(clickedModel)
                    },
                    setOnClickWriteReview: {
                        // 리뷰 작성뷰로 이동
                        getOnClickWriteReview(getVisitPlaceModel.placeModel.uid)
                        
                    }
                )
            }
        case .OTHER :
            switch selectedTabIndex {
            case 0:
                ReviewListView(
                    setPlaceModel: getVisitPlaceModel.placeModel,
                    setNationalityType: getNationalityType,
                    setOnClickCell: { clickedModel in
                        // 리뷰 셀 클릭이벤트
                        getOnClickReviewCell(clickedModel)
                    },
                    setOnClickWriteReview: {
                        // 리뷰 작성뷰로 이동
                        getOnClickWriteReview(getVisitPlaceModel.placeModel.uid)
                        
                    }
                )
            default:
                ReviewListView(
                    setPlaceModel: getVisitPlaceModel.placeModel,
                    setNationalityType: getNationalityType,
                    setOnClickCell: { clickedModel in
                        // 리뷰 셀 클릭이벤트
                        getOnClickReviewCell(clickedModel)
                    },
                    setOnClickWriteReview: {
                        // 리뷰 작성뷰로 이동
                        getOnClickWriteReview(getVisitPlaceModel.placeModel.uid)
                        
                    }
                )
            }
        }
    }
    
    var body : some View {
        VStack(spacing: 0) {
            // 탭 헤더
            tabHeader()
            
            // 컨텐츠 영역
            tabContent()
        }
    }
}
