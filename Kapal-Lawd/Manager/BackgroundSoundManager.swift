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

class BackgroundSoundManager: ObservableObject {
    public static var shared = BackgroundSoundManager()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var fadeTimer: Timer?
    private let fadeStepInterval: TimeInterval = 0.1
    
    func startPlayback(songTitle: String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found: \(songTitle)")
            return
        }
        
        // Initialize player item and player
        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        
        // Configure audio session for background playback
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Start playing
        self.player?.play()
        self.player?.volume = 0.5
        
    }
    
    func stopPlayback() {
        self.player?.pause()
        self.player?.pause()
        self.player = nil
        self.playerItem = nil
    }
}
