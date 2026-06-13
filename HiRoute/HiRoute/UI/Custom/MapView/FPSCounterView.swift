//
//  FPSCounterView.swift
//  HiRoute
//
//  Created by Claude on 3/13/26.
//

import SwiftUI

/// CADisplayLink 기반 FPS + frame time(ms) 측정
final class FPSCounter: ObservableObject {
    @Published var fps: Int = 0
    @Published var frameTimeMs: Double = 0.0

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0

    func start() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp

        if elapsed >= 0.5 {
            let currentFps = Double(frameCount) / elapsed
            let currentFrameTime = elapsed / Double(frameCount) * 1000.0

            DispatchQueue.main.async {
                self.fps = Int(round(currentFps))
                self.frameTimeMs = round(currentFrameTime * 100) / 100
            }

            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }

    deinit { stop() }
}

/// 지도 위 FPS 오버레이 (DEBUG 전용)
struct FPSOverlayView: View {
    @StateObject private var counter = FPSCounter()

    private var color: Color {
        if counter.frameTimeMs <= 18 { return .green }
        if counter.frameTimeMs <= 33 { return .yellow }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(counter.fps) fps")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
            Text("\(String(format: "%.1f", counter.frameTimeMs)) ms")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.85))
        .cornerRadius(6)
        .onAppear { counter.start() }
        .onDisappear { counter.stop() }
    }
}
