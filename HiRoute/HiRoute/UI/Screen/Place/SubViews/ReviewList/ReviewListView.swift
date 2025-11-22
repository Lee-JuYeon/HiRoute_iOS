//
//  ReviewListView.swift
//  HiRoute
//
//  Created by Jupond on 11/20/25.
//

import SwiftUI

struct ReviewListView : View {
    
    private var model : PlaceModel
    private var nationalityType : NationalityType
    private var callBackClickCell : (ReviewModel) -> Void
    private var callBackWriteReview : () -> Void
    init(
        setPlaceModel : PlaceModel,
        setNationalityType : NationalityType,
        setOnClickCell : @escaping (ReviewModel) -> Void,
        setOnClickWriteReview : @escaping () -> Void
    ){
        self.model = setPlaceModel
        self.nationalityType = setNationalityType
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
            LazyVStack(alignment: .leading, spacing: 0){
                reviewWriteButton()
                listFilterView()
                
                ForEach(model.reviews, id: \.reviewUID){ reviewModel in
                    ReviewCell(
                        setModel : reviewModel,
                        setNationalityType: nationalityType,
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
