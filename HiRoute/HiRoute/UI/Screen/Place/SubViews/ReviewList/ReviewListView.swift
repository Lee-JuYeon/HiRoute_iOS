//
//  ReviewListView.swift
//  HiRoute
//
//  Created by Jupond on 11/20/25.
//

import SwiftUI

struct ReviewListView : View {
    
    private var model : PlaceModel
    private var callBackClickCell : (ReviewModel) -> Void
    private var callBackWriteReview : () -> Void
    init(
        setPlaceModel : PlaceModel,
        setOnClickCell : @escaping (ReviewModel) -> Void,
        setOnClickWriteReview : @escaping () -> Void
    ){
        self.model = setPlaceModel
        self.callBackClickCell = setOnClickCell
        self.callBackWriteReview = setOnClickWriteReview
    }
    
    @ViewBuilder
    private func reviewWriteButton() -> some View {
        Button {
            callBackWriteReview()
        } label: {
            HStack(alignment: .center, spacing: 0){
                VStack(alignment: HorizontalAlignment.leading, spacing: 4, content: {
                    Text("\(model.title) 다녀오셨나요?")
                    HStack(alignment: .center, spacing: 0){
                        Text("리뷰를 작성하기")
                        Image("icon_arrow_right")
                    }
                })
                
                Image("img_review_write")
            }
        }
    }
    
    @State private var reviewListFilterType : ReviewListFilterType = .new
    @State private var expandFilterSheet : Bool = false
    @ViewBuilder
    private func listFilterView() -> some View {
        HStack(alignment: VerticalAlignment.center, spacing: 0){
            Text("\(reviewListFilterType.displayText)")
            Image("icon_arrow_down")
        }
        .onTapGesture {
            expandFilterSheet = true
        }
    }
    
//    @State private var onlyPhotoReview : Bool = false
//    @ViewBuilder
//    private func photoReviewFilterView() -> some View {
//        HStack(alignment : VerticalAlignment.center, spacing: 0){
//            Image(onlyPhotoReview ? "true colour" : "false gray" )
//            Text("사진 리뷰만")
//        }
//    }
    
    var body: some View {
        ScrollView(Axis.Set.vertical){
            VStack(alignment: .leading, spacing: 0){
                reviewWriteButton()
                listFilterView()
                
                ForEach(model.reviews, id: \.reviewUID){ reviewModel in
                    ReviewCell(
                        setModel : reviewModel,
                        onCallBackOption : { reviewUID in
                            
                        },
                        onCallBackUseful : { userUID in
                            
                        }
                    )
                }
            }
        }
        .bottomSheet(isOpen: $expandFilterSheet) {
            SheetReviewListFilter { filterType in
                reviewListFilterType = filterType
            }
        }
    }
}

struct SheetReviewListFilter : View {
    
    let onCallBackTypeClick : (ReviewListFilterType) -> Void
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0){
            Text(ReviewListFilterType.new.displayText)
                .onTapGesture {
                    onCallBackTypeClick(.new)
                }
            
            Text(ReviewListFilterType.recommend.displayText)
                .onTapGesture {
                    onCallBackTypeClick(.recommend)
                }
            
            Text(ReviewListFilterType.manyStar.displayText)
                .onTapGesture {
                    onCallBackTypeClick(.manyStar)
                }
            
            Text(ReviewListFilterType.littleStar.displayText)
                .onTapGesture {
                    onCallBackTypeClick(.littleStar)
                }
        }
    }
}

enum ReviewListFilterType : String, Codable {
    case new = "최신순"
    case recommend = "추천순"
    case manyStar = "별점 높은순"
    case littleStar = "별점 낮은순"
    
    var displayText: String {
        return self.rawValue
    }
}

