//
//  MiniAudioPlayerView.swift
//  HiRoute
//
//  Created by Jupond on 4/7/26.
//
import SwiftUI

struct MiniAudioPlayerView: View {
    @EnvironmentObject private var audioPlayerVM: AudioPlayerVM

    var body: some View {
        if audioPlayerVM.isVisible {
            HStack(spacing: 12) {
                // Title
                Text(audioPlayerVM.currentTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()

                // Play/Pause
                Button(action: {
                    audioPlayerVM.isPlaying ? audioPlayerVM.pause() : audioPlayerVM.resume()
                }) {
                    Image(systemName: audioPlayerVM.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                }

                // Progress text
                Text(formatTime(audioPlayerVM.currentTime))
                    .font(.system(size: 11, design: .monospaced))

                // Close
                Button(action: { audioPlayerVM.stop() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.85))
            .overlay(
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(
                            width: audioPlayerVM.duration > 0
                                ? geo.size.width * (audioPlayerVM.currentTime / audioPlayerVM.duration)
                                : 0,
                            height: 2
                        )
                }
                .frame(height: 2),
                alignment: .bottom
            )
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
