//
//  TypingIndicatorView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var phase: Int = 0
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.getColour(.label_neutral))
                    .frame(width: 6, height: 6)
                    .opacity(phase == index ? 1.0 : 0.3)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .onReceive(timer) { _ in
            phase = (phase + 1) % 3
        }
    }
}
