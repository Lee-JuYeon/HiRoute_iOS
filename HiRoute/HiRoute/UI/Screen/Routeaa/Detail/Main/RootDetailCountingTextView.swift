//
//  RootDetailCountingTextView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct RootDetailCountingTextView : View {
    var body: some View {
        Text("일정까지 D-13일 남았어요")
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.status_positive))
            .fontWeight(.bold)
            .lineLimit(1)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
    }
}
