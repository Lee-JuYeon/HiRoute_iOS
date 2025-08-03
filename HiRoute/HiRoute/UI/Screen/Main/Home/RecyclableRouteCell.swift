//
//  PlaceCell.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//

import SwiftUI



struct RecyclableRouteCell : View {
    
    let model: RouteModel
    let type: RouteCellType
    let onCellClickEvent: (RouteModel) -> Void
    let onBookMarkClickEvent: (String) -> Bool
    
    init(
        model: RouteModel,
        type: RouteCellType = .trendingRoute,
        onCellClickEvent: @escaping (RouteModel) -> Void,
        onBookMarkClickEvent: @escaping (String) -> Bool
    ) {
        self.model = model
        self.type = type
        self.onCellClickEvent = onCellClickEvent
        self.onBookMarkClickEvent = onBookMarkClickEvent
    }
    
    @ViewBuilder
    private func bookMarkButton() -> some View {
        Button {
            let newState = onBookMarkClickEvent(model.routeUID)
            
            // 햅틱 피드백
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            print("🔖 북마크 \(newState ? "추가" : "제거"): \(model.routeTitle)")
        } label: {
            Image(model.isBookmarkedLocally ? "icon_bookmark_on" : "icon_bookmark_off")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .customElevation(.normal)

        }
        .offset(x: type.bookmarkOffset.x, y: type.bookmarkOffset.y)
        .scaleEffect(model.isBookmarkedLocally ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: model.isBookmarkedLocally)
    }
    
    @ViewBuilder
    private func placeContent() -> some View {
        VStack(spacing: 0) {
            ServerHeightImageView(
                setImageURL: model.thumbNailImageURL,
                setImageHeight: type.imageHeight
            )
            
            VStack(alignment: .leading, spacing: type.contentSpacing) {
                Text(model.routeType)
                    .font(.system(size: type.categoryFontSize))
                    .foregroundColor(type.categoryColor)
                
                Text(model.routeTitle)
                    .font(.system(size: type.titleFontSize))
                    .foregroundColor(type.titleColor)
                    .fontWeight(.bold)
                
                HStack(
                    alignment: VerticalAlignment.center,
                    spacing: 2
                ) {
                    Image("icon_star_fill")
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fit)
                        .frame(width: 12, height: 12)
                    
                    Text("\(model.totalStarCount)・\(model.address.sido)")
                        .font(.system(size: type.infoFontSize))
                        .foregroundColor(type.infoColor)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, type.horizontalPadding)
            .padding(.vertical, type.verticalPadding)
        }
        .background(type.backgroundColor)
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
    }
}
