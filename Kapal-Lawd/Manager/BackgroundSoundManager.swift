//
//  BGSoundManager.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 28/10/24.
//

import Foundation
import AVKit

class BackgroundSoundManager: ObservableObject {
    public static var shared = BackgroundSoundManager()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var fadeTimer: Timer?
    private let fadeStepInterval: TimeInterval = 0.1
    @Published var isBackgroundPlaying = false
    
    init() {
        setupReplayObserver()
    }

    private func setupReplayObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(replayAudio),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    @objc
    private func replayAudio() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startPlayback(songTitle: String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found: \(songTitle)")
            return
        }
        
        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        self.player?.play()
        self.player?.volume = 0.3
        self.isBackgroundPlaying = true
    }
    
    func stopPlayback() {
        self.player?.pause()
        self.player?.pause()
        self.player = nil
        self.playerItem = nil
        self.isBackgroundPlaying = false
    }
}
