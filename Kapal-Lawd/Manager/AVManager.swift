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
    private let fadeStepInterval: TimeInterval = 0.1 // Time between volume adjustments
    
    @Published var isPlaying = false
    @Published var currentSongTitle: String?
    
    func startPlayback(songTitle: String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found: \(songTitle)")
            return
        }
        
        // Initialize player item and player
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Set initial volume to 0
        player?.volume = 0.0
        
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
    }
    
    func stopPlayback() {
        // Fade out to volume 0
        fadeToVolume(targetVolume: 0.0, duration: 1.0) { [weak self] in
            self?.player?.pause()
            self?.player = nil
            self?.playerItem = nil
            self?.isPlaying = false
            self?.currentSongTitle = nil
        }
    }
    
    // Method to fade to target volume
    func fadeToVolume(targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        
        guard let player = player else {
            completion?()
            return
        }
        
        let currentVolume = player.volume
        let volumeDifference = targetVolume - currentVolume
        let numberOfSteps = max(Int(duration / fadeStepInterval), 1)
        let volumeStep = volumeDifference / Float(numberOfSteps)
        
        var stepsCompleted = 0
        fadeTimer = Timer.scheduledTimer(
            withTimeInterval: fadeStepInterval,
            repeats: true
        ) { [weak self] timer in
            guard let self = self else { return }
            stepsCompleted += 1
            let newVolume = currentVolume + Float(stepsCompleted) * volumeStep
            self.player?.volume = max(0.0, min(1.0, newVolume))
            if stepsCompleted >= numberOfSteps {
                self.player?.volume = targetVolume
                timer.invalidate()
                completion?()
            }
        }
    }
    
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
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.pausePlayback()
                return .success
            }
            return .commandFailed
        }
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
}
