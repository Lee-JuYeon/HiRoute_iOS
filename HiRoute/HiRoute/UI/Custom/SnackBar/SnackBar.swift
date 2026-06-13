//
//  NeumorphicView.swift
//  HiRoute
//
//  Created by Jupond on 7/3/25.
//
import SwiftUI

struct SnackbarView: ViewModifier {
    
    @Binding var isOpen: Bool
    let message: String
    
    init(
        isOpen: Binding<Bool>,
        message: String
    ) {
        self._isOpen = isOpen
        self.message = message
    }
    
    @ViewBuilder
    private func snackbarUI() -> some View {
        VStack {
            Spacer()
            
            if isOpen {
                HStack {
                    Text(message)
                        .foregroundColor(Color.getColour(.background_white))
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.getColour(.label_strong).opacity(0.8))
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
                .allowsHitTesting(false) // ✅ 스낵바 자체만 터치 차단
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.15), value: isOpen)
            }
        }
        // ✅ 전체 VStack은 터치 이벤트 통과시킴
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(snackbarUI(), alignment: .bottom)
            .onChange(of: isOpen) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isOpen = false
                        }
                    }
                }
            }
    }
}

extension View {
    func snackbar(
        _ isOpen: Binding<Bool>,
        message: String
    ) -> some View {
        self.modifier(
            SnackbarView(
                isOpen: isOpen,
                message: message
            )
        )
    }
}
