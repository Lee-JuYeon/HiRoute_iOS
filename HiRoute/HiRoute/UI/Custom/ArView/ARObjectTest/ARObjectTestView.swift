//
//  ARObjectTestView.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import SwiftUI

// 실물 마커를 인식하고 RealityKit 오브젝트를 띄우는 테스트 화면.
struct ARObjectTestView: View {
    @State private var statusText = "마커 찾는 중"

    var body: some View {
        ZStack(alignment: .top) {
            // 실제 AR 카메라 화면만 띄운다.
            ARObjectTestContainer(statusText: $statusText)
                .ignoresSafeArea()

            Text(statusText)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(statusText == "마커 찾는 중" ? Color.black.opacity(0.75) : Color.green)
                .clipShape(Capsule())
                .padding(.top, 20)
        }
    }
}
