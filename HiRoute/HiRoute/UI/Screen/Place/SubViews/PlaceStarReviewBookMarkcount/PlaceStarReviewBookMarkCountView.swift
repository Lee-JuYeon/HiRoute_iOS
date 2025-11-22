//
//  ChipsView.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

struct PlaceStarReviewBookMarkCountView : View {
    
    let starCount : Int
    let reviewCount : Int
    let bookMarkCount : Int
    
    var body: some View {
        HStack(
           alignment: VerticalAlignment.center,
           spacing: 0
       ) {
           Image("icon_star_fill")
               .renderingMode(.template)
               .resizable()
               .foregroundColor(Color.getColour(.label_strong)) // 시스템 노란색
               .aspectRatio(contentMode: ContentMode.fit)
               .frame(width: 14, height: 14)

           Text("\(starCount) ・ 리뷰 \(reviewCount)개 ・ 북마크 \(bookMarkCount)회")
               .font(.system(size: 14))
               .foregroundColor(Color.getColour(.label_neutral))
       }
       .padding(
           EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12)
       )
    }
}
