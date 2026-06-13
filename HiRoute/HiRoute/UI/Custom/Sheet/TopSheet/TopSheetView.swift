//
//  TopSheetView.swift
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

    @State private var isPresented = false
    @State private var showContent = false
    @State private var offset: CGFloat = 0
    @State private var isDragging = false

    // MARK: - 닫기

    private func dismissSheet() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            var t = Transaction(animation: nil)
            t.disablesAnimations = true
            withTransaction(t) {
                isPresented = false
                isOpen = false
            }
            offset = 0
        }
    }

    // MARK: - 시트 UI

    @ViewBuilder private func topSheetUI() -> some View {
        ZStack(alignment: .top) {
            // 배경 탭 영역
            Color.gray.opacity(0.01)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissSheet()
                }

            // 시트 컨텐츠
            if showContent {
                VStack {
                    VStack {
                        self.getContent

                        RoundedRectangle(cornerRadius: 2.5)
                            .foregroundColor(.gray)
                            .frame(width: 36, height: 5)
                            .padding(.top, 16)
                    }
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5))
                    .background(Color.getColour(.background_white))
                    .clipShape(BottomRoundedRectangle(radius: 20, corners: [.bottomLeft, .bottomRight]))
                    .overlay(
                        BottomRoundedRectangle(radius: 20, corners: [.bottomLeft, .bottomRight])
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .offset(y: min(offset, 0))
                    .animation(isDragging ? .none : .easeInOut(duration: 0.25), value: offset)
                    .transition(.move(edge: .top))

                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height < 0 {
                                offset = value.translation.height
                                isDragging = true
                            }
                        }
                        .onEnded { value in
                            if offset < -100 {
                                dismissSheet()
                            } else {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    offset = 0
                                }
                            }
                            isDragging = false
                        }
                )
            }
        }
        .background(
            BackgroundBlurView()
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.25)) {
                showContent = true
            }
        }
        .onDisappear {
            showContent = false
            offset = 0
        }
    }

    // MARK: - body

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                topSheetUI()
            }
            .onChange(of: isOpen) { newValue in
                if newValue {
                    // fullScreenCover 애니메이션 제거 → 즉시 표시
                    var t = Transaction(animation: nil)
                    t.disablesAnimations = true
                    withTransaction(t) {
                        isPresented = true
                    }
                }
            }
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
