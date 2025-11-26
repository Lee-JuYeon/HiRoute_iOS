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
    private var getModeType: ModeType
    private var onTextChanged: (String) -> Void
    
    init(
        setHint: String,
        setText: Binding<String>,
        setModeType: ModeType,
        onTextChanged: @escaping (String) -> Void
    ) {
        self.getHint = setHint
        self._getText = setText
        self.getModeType = setModeType
        self.onTextChanged = onTextChanged
    }
    
    var body: some View {
        if getModeType == .READ {
            // ✅ 읽기 모드
            ScrollView(.vertical, showsIndicators: true) {
                Text(getText.isEmpty ? getHint : getText)
                    .font(.system(size: 16))
                    .foregroundColor(getText.isEmpty ? Color.getColour(.label_alternative) : Color.getColour(.label_normal))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
            .frame(height: 60)
        } else {
            // ✅ 편집 모드 - iOS 14 완전 호환
            ZStack(alignment: .topLeading) {
                // 배경색 설정 (TextEditor의 기본 배경 덮어쓰기)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.getColour(.background_white))
                    .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                
                // 힌트 텍스트
                if getText.isEmpty {
                    Text(getHint)
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_alternative))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
                
                // TextEditor
                TextEditor(text: $getText)
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_normal))
                    .background(Color.clear)
                    .padding(4)
                    .onChange(of: getText) { oldValue, newValue in
                        onTextChanged(newValue)
                    }
            }
            .frame(height: 80)
        }
    }
}
