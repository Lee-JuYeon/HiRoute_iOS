//
//  RootDetailTitleView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct RootDetailTitleView : View {
    
    private let rootTitle : String = "일정명 영역 공백 포함 최대이십자까지 supporing"

    var body: some View {
        Text(rootTitle.count > 20 ? String(rootTitle.prefix(20)) + "..." : rootTitle)
            .font(.system(size: 24))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}
