//
//  MultiLineMemoView.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//
import SwiftUI

struct MultiLineMemoView: View {
    
    private var getHint: String
    @Binding private var getText: String
    private var getModeType: ModeType

    
    init(
        setHint: String,
        setText: Binding<String>,
        setModeType: ModeType,
    ) {
        self.getHint = setHint
        self._getText = setText
        self.getModeType = setModeType
    }
    
    var body: some View {
        if getModeType == .READ {
            // ✅ 읽기 모드
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
        } else {
            // ✅ 편집 모드 - UIKit TextViewf 사용
            MultiLineTextField(
                text: $getText,
                placeholder: getHint,
                onTextChanged: { changedText in
                    
                }
            )
            .frame(height: 80)
            .background(Color(UIColor.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
