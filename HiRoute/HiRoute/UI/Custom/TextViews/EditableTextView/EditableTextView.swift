//
//  EditableTextView.swift
//  HiRoute
//
//  Created by Jupond on 12/19/25.
//

import SwiftUI

struct EditableTextView: View {
    
    /*
     - 제목용 (기본): horizontal, single line, size 20
     - 글작성용: vertical, multiline, size 16
     */
    @Binding private var getTitle: String
    private let getHint : String
    private let getCallBackClick: () -> Void
    private let getAlignment: Axis.Set
    private let getIsMultiline: Bool
    private let getTextSize: CGFloat
    
    init(
        setTitle: Binding<String>,
        setHint : String,
        callBackClick: @escaping () -> Void,
        setAlignment: Axis.Set = .horizontal,  // ✅ 기본값 수정
        isMultiLine: Bool = false,
        setTextSize: CGFloat = 20  // ✅ 기본값 수정
    ) {
        self._getTitle = setTitle
        self.getHint = setHint
        self.getCallBackClick = callBackClick
        self.getAlignment = setAlignment
        self.getIsMultiline = isMultiLine
        self.getTextSize = setTextSize
    }
    
    @ViewBuilder
    private func customModifier<Content: View>(_ content: Content) -> some View {
        if getAlignment == .horizontal {
            content.fixedSize(horizontal: true, vertical: false)
        } else {
            content.fixedSize(horizontal: false, vertical: true)
        }
    }
    
    var body: some View {
        ScrollView(getAlignment, showsIndicators: false) {
            customModifier(
                Text(getTitle.count != 0 ? getTitle : getHint)
                    .font(.system(size: getTextSize))
                    .foregroundColor(Color.getColour(getTitle.count == 0 ? .label_alternative : .label_normal))
                    .multilineTextAlignment(.leading)
                    .lineLimit(getIsMultiline ? nil : 1)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: getIsMultiline ? 60 : 30) // ✅ 높이 조정
        .onTapGesture {
            getCallBackClick()
        }
    }
    
    
}
