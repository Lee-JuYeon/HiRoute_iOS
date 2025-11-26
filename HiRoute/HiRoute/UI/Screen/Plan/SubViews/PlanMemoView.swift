//
//  SimpleUserModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct PlanMemoView: View {
    
    private var getHint: String
    @Binding private var getText: String
    private var onClick: (String) -> Void
    
    init(
        setHint: String,
        setText: Binding<String>,
        setOnClick: @escaping (String) -> Void
    ) {
        self.getHint = setHint
        self._getText = setText
        self.onClick = setOnClick
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Text(getText)
                .font(.system(size: 16))
                .foregroundColor(Color.getColour(.label_normal))
                .multilineTextAlignment(.leading)
                .lineLimit(nil) // 무제한 줄 표시
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .frame(height: 60) // 3줄 높이만큼 제한
    
    }
}
