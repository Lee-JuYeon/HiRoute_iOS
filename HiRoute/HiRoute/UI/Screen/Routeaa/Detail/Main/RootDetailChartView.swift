//
//  RootDetailChartView.swift
//  HiRoute
//
//  Created by Jupond on 7/18/25.
//

import SwiftUI

struct RootDetailChartView : View {
    
   
    private var getDate : String
    private var getAddress : String
    private var getRootStyle : String?
    private var getWeather : String?
    private var getOnClick : () -> Void
    init(
        setDate : String,
        setAddress : String,
        setRootStyle : String?,
        setWeather : String?,
        setOnClick : @escaping () -> Void
    ){
        self.getDate = setDate
        self.getAddress = setAddress
        self.getRootStyle = setRootStyle
        self.getWeather = setWeather
        self.getOnClick = setOnClick
    }
   
   
    private let horizontalSpacing : CGFloat = 13
    private let verticalSpacing : CGFloat = 6
    private let backgroundCornerRadius : CGFloat = 12
    private let backgroundInnerPaddingSize : CGFloat = 16
    private let backgroundMarginSize : CGFloat = 16
    
    @ViewBuilder
    private func rowText(emoji: String, title: String, content: String?, contentHint: String) -> some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width - horizontalSpacing  // spacing 제외
            let leftWidth = totalWidth / 3      // 1:2 비율의 1 부분
            let rightWidth = totalWidth * 2 / 3 // 1:2 비율의 2 부분
            
            HStack(alignment: .center, spacing: horizontalSpacing) {
                Text("\(emoji) \(title)")
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_neutral))
                    .fontWeight(.none)
                    .lineLimit(1)
                    .frame(width: leftWidth, alignment: .leading)
                
                Text("\(content ?? contentHint)")
                    .font(.system(size: 16))
                    .foregroundColor(content != nil ? Color.getColour(.label_strong) : Color.getColour(.label_alternative))
                    .fontWeight(content != nil ? .bold : .light)
                    .lineLimit(1)
                    .frame(width: rightWidth, alignment: .leading)
            }
        }
        .frame(height: 22)
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: verticalSpacing){
            rowText(emoji: "📅", title: "일자", content: getDate, contentHint: "날짜를 입력하세요")
            rowText(emoji: "📌", title: "장소", content: getAddress, contentHint: "장소를 입력하세요")
            rowText(emoji: "🎭", title: "루트 스타일", content: getRootStyle, contentHint: "루트 스타일을 선택해 주세요")
            rowText(emoji: "🌈", title: "예상 날씨", content: getWeather, contentHint: "아직 조회할 수 없어요")
        }
        .onTapGesture {
            getOnClick()
        }
        .padding(EdgeInsets(
            top: backgroundInnerPaddingSize,
            leading: backgroundInnerPaddingSize,
            bottom: backgroundInnerPaddingSize,
            trailing: backgroundInnerPaddingSize
        ))
        .background(
            RoundedRectangle(cornerRadius: backgroundCornerRadius)
                .fill(Color.getColour(.background_white))
                .customElevation(.normal)
        )
        .padding(EdgeInsets(
            top: backgroundMarginSize,
            leading: backgroundMarginSize,
            bottom: backgroundMarginSize,
            trailing: backgroundMarginSize
        ))
        
    }
}
