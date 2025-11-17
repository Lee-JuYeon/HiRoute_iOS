//
//  PlaceCell.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//

import SwiftUI

struct RecommendPlaceCell : View {
    
    let model: PlaceModel
    let onCellClickEvent: (PlaceModel) -> Void
    let onBookMarkClickEvent: (String) -> Bool
    
    init(
        model: PlaceModel,
        onCellClickEvent: @escaping (PlaceModel) -> Void,
        onBookMarkClickEvent: @escaping (String) -> Bool
    ) {
        self.model = model
        self.onCellClickEvent = onCellClickEvent
        self.onBookMarkClickEvent = onBookMarkClickEvent
    }
    
    private let imageSize: CGFloat = 120
    private var cellHeight: CGFloat {
        return imageSize + 80 // 이미지 + 텍스트 영역 + 패딩
    }
      
    
    @ViewBuilder
    private func bookMarkButton() -> some View {
        Button {
            let newState = onBookMarkClickEvent(model.uid)
            
            // 햅틱 피드백
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            print("🔖 북마크 \(newState ? "추가" : "제거"): \(model.title)")
        } label: {
            Image(model.isBookmarkedLocally ? "icon_bookmark_on" : "icon_bookmark_off")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .customElevation(.normal)

        }
        .scaleEffect(model.isBookmarkedLocally ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: model.isBookmarkedLocally)
        .padding([.top, .trailing], 5) // 우측 상단에서 5dp 띄우기
    }
    
    @ViewBuilder
    private func placeContent() -> some View {
        VStack(spacing: 0) {
            ServerImageView(
                setImageURL: model.thumbanilImageURL ?? "",
                setImageSize: imageSize,
                setPlaceHolder: "",
                setCornerRadius: 20
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.type.displayText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(model.title)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                
                HStack(
                    alignment: VerticalAlignment.center,
                    spacing: 2
                ) {
                    Image("icon_star_fill")
                        .resizable()
                        .foregroundColor(Color.yellow) // 시스템 노란색
                        .aspectRatio(contentMode: ContentMode.fit)
                        .frame(width: 12, height: 12)

                    Text("\(model.totalStarCount)・\(model.address.sido)")
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
