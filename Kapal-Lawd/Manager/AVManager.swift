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
    @Published var isPlaying = false
    @Published var currentSongTitle: String?

    func startPlayback(songTitle: String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        self.playerItem = playerItem
        self.player = AVPlayer(playerItem: playerItem)
        
        // Set audio session for background playback
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Start playing
        self.player?.play()
        self.isPlaying = true
        self.currentSongTitle = songTitle
        
        // Update lock screen info
        updateNowPlayingInfo(songTitle: songTitle)
        
        // Semtup remote transport controls
        setupRemoteTransportControls()
    }

    func pausePlayback() {
        self.player?.pause()
        self.isPlaying = false
        updateNowPlayingInfo(songTitle: currentSongTitle ?? "")
    }

    func resumePlayback() {
        self.player?.play()
        self.isPlaying = true
        updateNowPlayingInfo(songTitle: currentSongTitle ?? "")
    }

    func stopPlayback() {
        self.player?.pause()
        self.player?.seek(to: CMTime.zero)
        self.isPlaying = false
        updateNowPlayingInfo(songTitle: currentSongTitle ?? "")
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
