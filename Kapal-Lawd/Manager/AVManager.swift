//
//  AVManager.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 26/09/24.
//

import Foundation
import AVKit
import Combine
import MediaPlayer

class AVManager: ObservableObject {
    public static var shared = AVManager()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var fadeTimer: Timer?
    private var fadeVolume: Float = 0.0
    private let fadeDuration: TimeInterval = 2.0 // Duration for fade-in and fade-out
    
    @Published var isPlaying = false
    @Published var currentSongTitle: String?

    func startPlayback(songTitle: String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        // Initialize player item and player
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Set initial volume to 0 for fade-in
        player?.volume = 0.0
        fadeVolume = 0.0
        
        // Configure audio session for background playback
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Start playing
        player?.play()
        isPlaying = true
        currentSongTitle = songTitle
        
        // Update lock screen info
        updateNowPlayingInfo(songTitle: songTitle)
        
        // Setup remote transport controls
        setupRemoteTransportControls()
        
        // Start fade-in effect
        startFadeIn()
    }

    func pausePlayback() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo(songTitle: currentSongTitle ?? "")
    }

    func resumePlayback() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfo(songTitle: currentSongTitle ?? "")
    }

    func stopPlayback() {
        // Start fade-out effect
        startFadeOut()
    }
}

extension AVManager {
    private func updateNowPlayingInfo(songTitle: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songTitle

        if let playerItem = self.playerItem {
            let duration = CMTimeGetSeconds(playerItem.asset.duration)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(playerItem.currentTime())
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.isPlaying ? 1.0 : 0.0
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            if !self.isPlaying {
                self.resumePlayback()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            print("Next track")
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            print("Previous track")
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.pausePlayback()
                return .success
            }
            return .commandFailed
        }
    }
}

extension AVManager {
    // MARK: - Fade-In and Fade-Out Methods
    
    private func startFadeIn() {
        fadeTimer?.invalidate()
        fadeVolume = 0.0
        player?.volume = fadeVolume
        
        let fadeStep = 0.1 / Float(fadeDuration) // Adjust volume every 0.1 seconds
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.fadeVolume += fadeStep
            if self.fadeVolume >= 1.0 {
                self.fadeVolume = 1.0
                self.player?.volume = self.fadeVolume
                timer.invalidate()
            } else {
                self.player?.volume = self.fadeVolume
            }
        }
    }
    
    private func startFadeOut() {
        fadeTimer?.invalidate()
        fadeVolume = player?.volume ?? 1.0
        
        let fadeStep = 0.1 / Float(fadeDuration)
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.fadeVolume -= fadeStep
            if self.fadeVolume <= 0.0 {
                self.fadeVolume = 0.0
                self.player?.volume = self.fadeVolume
                timer.invalidate()
                self.player?.pause()
                self.player = nil
                self.playerItem = nil
                self.isPlaying = false
                self.currentSongTitle = nil
            } else {
                self.player?.volume = self.fadeVolume
            }
        }
    }
}
