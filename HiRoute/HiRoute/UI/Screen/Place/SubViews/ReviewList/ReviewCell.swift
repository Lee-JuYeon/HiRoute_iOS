//
//  ReviewCell.swift
//  HiRoute
//
//  Created by Jupond on 11/20/25.
//

import SwiftUI

struct ReviewCell : View {
    
    private var model : ReviewModel
    private var nationalityType : NationalityType
    private var callBackOption : (String) -> Void
    private var callBackUseful : (String) -> Void
    init(
        setModel : ReviewModel,
        setNationalityType : NationalityType,
        onCallBackOption : @escaping (String) -> Void,
        onCallBackUseful : @escaping (String) -> Void
    ){
        self.model = setModel
        self.nationalityType = setNationalityType
        self.callBackOption = onCallBackOption
        self.callBackUseful = onCallBackUseful
    }
    
    @State private var selectedModel : ReviewModel?
    @State private var sheetOption : Bool = false

    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 10){
            HStack(alignment: VerticalAlignment.center, spacing: 0){
                Text("\(model.userName)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Text("\(model.visitDate.toLocalizedDateString(region: nationalityType)) 방문")
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.label_neutral))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                
                Spacer()
                
                Image("icon_dots")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_alternative))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(90))
                    .onTapGesture {
                        sheetOption.toggle()
                        callBackOption(model.reviewUID)
                    }
            }
            
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack(alignment: .center, spacing: 4){
                    ForEach(model.images, id: \.userUID){ imageModel in
                        ServerImageView(setImageURL: imageModel.imageURL)
                            .frame(
                                height: 103
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                            .onTapGesture {
                                selectedModel = model
                            }
                    }
                }
            }
            
            Text(model.reviewText)
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_normal))
                .fontWeight(.light)
                .multilineTextAlignment(.leading)
            
            HStack(alignment: VerticalAlignment.center, spacing: 2){
                Text("도움 돼요")
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Image(model.usefulList.contains(where: { usefulModel in
                    usefulModel.userUID == DummyPack.shared.myDataUID
                }) ? "icon_like_on" : "icon_like_off")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        callBackUseful(model.userUID)
                    }
                
                Text("\(model.usefulList.count)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
            
        }
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        .background(Color.getColour(.background_white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .customElevation(.normal)
        .bottomSheet(isOpen: $sheetOption) {
            SheetReviewCellOptionView(
                setReviewModel: model,
                onCallBackReport: { reviewModel, reportTypeDisplayText in
                    
                }
            )
        }
        .fullScreenCover(item: $selectedModel) { reviewModel in
            FullSizeImageListView(setImageList: reviewModel.images)
        }
    }
}
