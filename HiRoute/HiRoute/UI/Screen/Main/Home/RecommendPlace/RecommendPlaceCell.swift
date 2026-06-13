//
//  PlaceCell.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//

import SwiftUI

struct RecommendPlaceCell : View {
    
    let model: PlaceModel
    let isBookmarked: Bool
    let onCellClickEvent: (PlaceModel) -> Void
    let onBookMarkClickEvent: (String) -> Void

    init(
        model: PlaceModel,
        isBookmarked: Bool,
        onCellClickEvent: @escaping (PlaceModel) -> Void,
        onBookMarkClickEvent: @escaping (String) -> Void
    ) {
        self.model = model
        self.isBookmarked = isBookmarked
        self.onCellClickEvent = onCellClickEvent
        self.onBookMarkClickEvent = onBookMarkClickEvent
    }
    
    private let imageSize: CGFloat = 120
    private let cornerRadius : CGFloat = 20
    private var cellHeight: CGFloat {
        return imageSize + 80 // 이미지 + 텍스트 영역 + 패딩
    }
      
    
    @ViewBuilder
    private func bookMarkButton() -> some View {
        Button {
            onBookMarkClickEvent(model.uid)

            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            Image(isBookmarked ? "icon_bookmark_on" : "icon_bookmark_off")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_strong))
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .customElevation(.normal)
        }
        .scaleEffect(isBookmarked ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isBookmarked)
        .padding([.top, .trailing], 5)
    }
    
    @ViewBuilder
    private func placeContent() -> some View {
        VStack(spacing: 0) {
            ServerImageView(
                setImageURL: model.thumbnailImage?.imageUrl ?? ""
            )
            .frame(width: 150, height: imageSize)
            .clipped()
            .aiWatermark(isAiGenerated: model.thumbnailImage?.isAiGenerated ?? false, size: .thumbnail)

            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.type.displayText)
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .lineLimit(1)

                Text(model.title)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_normal))
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                
                HStack(
                    alignment: VerticalAlignment.center,
                    spacing: 2
                ) {
                    Image("icon_star_fill")
                        .resizable()
                        .foregroundColor(Color.getColour(.label_neutral)) // 시스템 노란색
                        .aspectRatio(contentMode: ContentMode.fit)
                        .frame(width: 12, height: 12)

                    Text("\((model.stars ?? []).count)・\(model.address.addressBlock1 ?? "")")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                }
                
                Spacer()
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .customElevation(.normal)
        .onTapGesture {
            onCellClickEvent(model)
        }
    }
    
    var body: some View {
        ZStack(alignment: Alignment.topTrailing){
            placeContent()
            bookMarkButton()
        }
        .frame(width: 150, height: cellHeight)
    }
}
