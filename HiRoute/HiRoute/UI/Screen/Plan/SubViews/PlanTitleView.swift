//
//  RootDetailTitleView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct PlanTitleView : View {
    
    let title : String

    var body: some View {
        Text(title.count > 20 ? String(title.prefix(20)) + "..." : title)
            .font(.system(size: 20))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
}
