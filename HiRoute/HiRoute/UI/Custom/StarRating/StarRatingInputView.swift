//
//  StarRatingInputView.swift
//  HiRoute
//
//  Created by Jupond on 3/2/26.
//

import SwiftUI

/// 별점 입력 뷰 (1~5점). 같은 별 다시 탭 시 초기화(0).
struct StarRatingInputView: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { index in
                Image(index <= rating ? "icon_star_fill" : "icon_star_stroke")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color.getColour(.label_strong))
                    .onTapGesture {
                        rating = (rating == index) ? 0 : index
                    }
            }
        }
    }
}
