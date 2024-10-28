//
//  BGSoundManager.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 28/10/24.
//

import Foundation
import AVKit
import Combine
import MediaPlayer

class BGSoundManager: ObservableObject {
    public static var shared = BGSoundManager()
    let commandCenter = MPRemoteCommandCenter.shared()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var fadeTimer: Timer?
    private let fadeStepInterval: TimeInterval = 0.1
    @Published var playlist: [Playlist] = []
    private var _currentPlaylistIndex: Int = 0
    @Published var isPlaying = false
    @Published var currentSongTitle: String?
    private var commandHandlersSetup = false

    var currentPlaylistIndexPublisher = PassthroughSubject<Int, Never>()
    
    var currentPlaylistIndex: Int {
        get {
            return _currentPlaylistIndex
        }
        set {
            _currentPlaylistIndex = newValue
            currentPlaylistIndexPublisher.send(newValue)
            print("Curent Playlist On Index: \(newValue)")
        }
    }

    func startPlayback(songTitle: String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found: \(songTitle)")
            return
        }
        
        // Initialize player item and player
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Configure audio session for background playback
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Start playing
        player?.play()
        isPlaying = true
        currentSongTitle = songTitle
        
    }
    
    func stopPlayback() {
        // Fade out to volume 0
        fadeToVolume(targetVolume: 0.0, duration: 1.0) { [weak self] in
            self?.player?.pause()
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
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
}
