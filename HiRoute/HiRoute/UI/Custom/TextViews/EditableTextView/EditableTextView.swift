//
//  EditableTextView.swift
//  HiRoute
//
//  Created by Jupond on 12/19/25.
//

import SwiftUI

struct EditableTextView: View {
    
    @Binding private var getTitle: String
    @Binding private var editmode: ModeType
    private let getHint: String
    private let getCallBackClick: () -> Void
    private let getAlignment: Axis.Set
    private let getIsMultiline: Bool
    private let getTextSize: CGFloat
    
    init(
        setTitle: Binding<String>,
        setHint: String,
        setEditMode: Binding<ModeType>,
        setAlignment: Axis.Set = .horizontal,
        isMultiLine: Bool = false,
        setTextSize: CGFloat = 20,
        callBackClick: @escaping () -> Void,
    ) {
        self._getTitle = setTitle
        self._editmode = setEditMode
        self.getHint = setHint
        self.getCallBackClick = callBackClick
        self.getAlignment = setAlignment
        self.getIsMultiline = isMultiLine
        self.getTextSize = setTextSize
    }
    
    private var dynamicHeight: CGFloat {
        if getIsMultiline {
            let lineHeight = getTextSize * 1.2
            return lineHeight  // READ/EDIT 동일하게 1줄 높이
        }
        return 30
    }

    private var dynamicMaxHeight: CGFloat {
        if getIsMultiline {
            let lineHeight = getTextSize * 1.2
            return lineHeight * 5  // READ/EDIT 동일하게 최대 5줄
        }
        return 30
    }
    
    @ViewBuilder
    private func customModifier<Content: View>(_ content: Content) -> some View {
        if getAlignment == .horizontal {
            content.fixedSize(horizontal: true, vertical: false)
        } else {
            content.fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    private func readModeView() -> some View {
        Text(getTitle.count != 0 ? getTitle : getHint)
            .font(.system(size: getTextSize))
            .foregroundColor(Color.getColour(getTitle.count == 0 ? .label_alternative : .label_normal))
            .multilineTextAlignment(.leading)
            .lineLimit(getIsMultiline ? 5 : 1)
    }
    
    @ViewBuilder
    private func editModeView() -> some View {
        if getIsMultiline {
            ZStack(alignment: .topLeading) {
                if #available(iOS 16.0, *) {
                    TextEditor(text: $getTitle)
                        .font(.system(size: getTextSize))
                        .foregroundColor(Color.getColour(.label_normal))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.all, 0)
                } else {
                    // iOS 15 이하 대응
                    TextEditor(text: $getTitle)
                        .font(.system(size: getTextSize))
                        .foregroundColor(Color.getColour(.label_normal))
                        .background(Color.clear)
                        .padding(.all, 0)
                        .onAppear {
                            // iOS 15에서 TextEditor 배경 제거
                            UITextView.appearance().backgroundColor = .clear
                        }
                }
                
                if getTitle.isEmpty {
                    Text(getHint)
                        .font(.system(size: getTextSize))
                        .foregroundColor(Color.getColour(.label_alternative))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
            }
            .background(Color.clear)
        } else {
            TextField(getHint, text: $getTitle)
                .font(.system(size: getTextSize))
                .foregroundColor(Color.getColour(.label_normal))
                .textFieldStyle(PlainTextFieldStyle())
                .lineLimit(1)
                .background(Color.clear)
        }
    }
    
    
    private var iOS16Available: Bool {
        if #available(iOS 16.0, *) {
            return true
        }
        return false
    }
    
    var body: some View {
        ScrollView(getAlignment, showsIndicators: false) {
            customModifier(
                Group {
                    if editmode == .READ {
                        readModeView()
                    } else {
                        editModeView()
                    }
                }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .frame(minHeight: dynamicHeight, maxHeight: dynamicMaxHeight)
        .onTapGesture {
            getCallBackClick()
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
