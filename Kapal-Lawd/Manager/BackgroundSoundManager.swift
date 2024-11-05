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
        configureAudioSession()
        
        guard let url = URL(string: AudiumBackendService.baseURL+songTitle) else {
            print("Invalid URL")
            return
        }
        
        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        
        self.player?.play()
        self.player?.volume = 0.1
        self.isBackgroundPlaying = true
    }
    
    func stopPlayback() {
        self.player?.pause()
        self.player = nil
        self.playerItem = nil
        self.isBackgroundPlaying = false
    }
    
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(.playback, mode: .default)
            
            try session.setActive(true)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
