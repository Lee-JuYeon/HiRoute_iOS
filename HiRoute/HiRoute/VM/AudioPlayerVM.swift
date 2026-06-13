//
//  AudioPlayerVM.swift
//  HiRoute
//
//  Created by Jupond on 4/7/26.
//
import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioPlayerVM: ObservableObject {

    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentTitle: String = ""
    @Published var isVisible = false

    private var player: AVPlayer?
    private var timeObserver: Any?

    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioPlayerVM, setupAudioSession // Warning : AudioSession error - \(error)")
        }
    }

    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
    }

    func play(url: String, title: String) {
        guard let audioURL = URL(string: url) else { return }

        stop()

        let item = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: item)
        currentTitle = title
        isVisible = true

        // Duration (available after asset loads)
        if let dur = player?.currentItem?.asset.duration, dur.isNumeric {
            duration = CMTimeGetSeconds(dur)
        }

        // Periodic time observer
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = CMTimeGetSeconds(time)
            // Update duration once available from stream
            if let dur = self?.player?.currentItem?.duration, dur.isNumeric {
                self?.duration = CMTimeGetSeconds(dur)
            }
        }

        // Completion observer
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
            self?.currentTime = 0
            self?.player?.seek(to: .zero)
        }

        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func resume() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func stop() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentTitle = ""
        isVisible = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentTitle
        info[MPMediaItemPropertyArtist] = "Nunulala"
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    deinit {
        stop()
    }
}
