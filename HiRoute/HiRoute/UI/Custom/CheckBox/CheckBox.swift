//
//  CheckBox.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//

import SwiftUI

struct CheckBox: View {
    
    @Binding var isChecked: Bool
    let onToggle: (() -> Void)?
    
    init(isChecked: Binding<Bool>, onToggle: (() -> Void)? = nil) {
        self._isChecked = isChecked
        self.onToggle = onToggle
    }
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
            onToggle?()
        }) {
            ZStack {
                Circle()
                    .fill(isChecked ? Color.black : Color.white)  // ✅ 체크시 검은색, 아닐때 흰색
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: isChecked ? 0 : 1)  // ✅ 미체크시에만 회색 테두리
                    )
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)  // ✅ 체크시 하얀색 체크마크
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)  // ✅ 미체크시 회색 체크마크
                        .opacity(0.3)  // 살짝 투명하게
                }
            }
        }
        .buttonStyle(PlainButtonStyle())  // 기본 버튼 스타일 제거
    }
}
