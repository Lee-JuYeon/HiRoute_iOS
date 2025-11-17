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
//        VStack(alignment: .leading, spacing: 8) {
//            Text("메모")
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(.primary)
//            
//            if #available(iOS 16.0, *) {
//                // ✅ iOS 16+ 멀티라인 TextField
//                TextField(getHint, text: $getText, axis: .vertical)
//                    .font(.system(size: 16))
//                    .foregroundColor(.primary)
//                    .padding(12)
//                    .background(Color(UIColor.systemBackground))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.yellow, lineWidth: 1)
//                    )
//                    .cornerRadius(12)
//                    .lineLimit(3...6)
//                    .onSubmit {
//                        onClick(getText)
//                    }
//            } else if #available(iOS 15.0, *) {
//                // ✅ iOS 15 TextField
//                TextField(getHint, text: $getText)
//                    .font(.system(size: 16))
//                    .foregroundColor(.primary)
//                    .padding(12)
//                    .background(Color(UIColor.systemBackground))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.yellow, lineWidth: 1)
//                    )
//                    .cornerRadius(12)
//                    .onSubmit {
//                        onClick(getText)
//                    }
//            } else {
//                // ✅ iOS 14 이하 - TextEditor 사용
//                ZStack(alignment: .topLeading) {
//                    TextEditor(text: $getText)
//                        .font(.system(size: 16))
//                        .foregroundColor(.primary)
//                        .background(Color(UIColor.systemBackground))
//                    
//                    // 플레이스홀더 구현
//                    if getText.isEmpty {
//                        Text(getHint)
//                            .font(.system(size: 16))
//                            .foregroundColor(.secondary)
//                            .padding(.top, 8)
//                            .padding(.leading, 5)
//                            .allowsHitTesting(false)
//                    }
//                }
//                .frame(height: 100)
//                .padding(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.yellow, lineWidth: 1)
//                )
//                .cornerRadius(12)
//                .onTapGesture {
//                    // 텍스트 에디터 포커스를 위한 더미 탭
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 8)
        Text(getText)
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.label_normal))
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    
    }
}
