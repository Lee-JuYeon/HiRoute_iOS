//
//  RootDetailTitleView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct TopSheetView<GetView: View>: ViewModifier {
    
    @Binding var isOpen: Bool
    @ViewBuilder private let getContent: GetView

    init(
        isOpen: Binding<Bool>,
        @ViewBuilder setContent: @escaping () -> GetView
    ) {
        self._isOpen = isOpen
        self.getContent = setContent()
    }
    
    @GestureState private var translation: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var isDragging = false

    @ViewBuilder
    private func topSheetUI() -> some View {
        ZStack {
            Color.gray.opacity(0.01)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isOpen = false
                    }
                }
           
            GeometryReader { geometry in
                VStack {
                    VStack {
                        self.getContent
                        
                        RoundedRectangle(cornerRadius: 2.5)
                            .foregroundColor(.gray)
                            .frame(width: 36, height: 5)
                            .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
                    }
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5))
                    .background(Color.getColour(.background_white))
                    .clipShape(BottomRoundedRectangle(radius: 20, corners: [.bottomLeft, .bottomRight]))
                    .overlay(
                        BottomRoundedRectangle(radius: 20, corners: [.bottomLeft, .bottomRight])
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: min(geometry.size.height - geometry.safeAreaInsets.bottom, geometry.size.height * 0.9),
                        alignment: .top
                    )
                    .transition(.move(edge: .top))
                    // ✅ 수정: 아래로 드래그하면 sheet가 아래로 따라옴
                    .offset(y: max(offset, 0))  // 양수로 아래쪽 이동
                    .animation(isDragging ? .none : .easeInOut, value: offset)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .gesture(
                    DragGesture()
                        .updating($translation) { value, state, _ in
                            state = value.translation.height
                        }
                        .onChanged { value in
                            // ✅ 아래로 드래그할 때 (양수)
                            if value.translation.height > 0 {
                                offset = value.translation.height
                                isDragging = true
                            }
                        }
                        .onEnded { value in
                            // ✅ 아래로 충분히 드래그하면 닫기
                            if offset > geometry.size.height / 3 {
                                withAnimation {
                                    isOpen = false
                                }
                            } else {
                                withAnimation {
                                    offset = 0
                                }
                            }
                            isDragging = false
                        }
                )
                .onDisappear {
                    offset = 0
                }
            }
        }
        .background(
            BackgroundBlurView()
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(
                isPresented: $isOpen,
                content: {
                    topSheetUI()
                }
            )
    }
}

extension View {
    func topSheet<GetView: View>(
        isOpen: Binding<Bool>,
        @ViewBuilder setContent: @escaping () -> GetView
    ) -> some View {
        self.modifier(
            TopSheetView(
                isOpen: isOpen,
                setContent: setContent
            )
        )
    }
}
