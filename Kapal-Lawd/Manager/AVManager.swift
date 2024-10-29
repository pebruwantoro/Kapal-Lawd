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
    let commandCenter = MPRemoteCommandCenter.shared()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var fadeTimer: Timer?
    private let fadeStepInterval: TimeInterval = 0.1 // Time between volume adjustments
    @Published var playlist: [Playlist] = []
    private var _currentPlaylistIndex: Int = 0
    @Published var isPlaying = false
    @Published var currentSongTitle: String?
    private var commandHandlersSetup = false
    var cancellable: AnyCancellable?
    @Published var currentTimeInSeconds: Double = 0.0
    private var timeObserverToken: Any?
    
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
        removeTimeObserver()
        
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found: \(songTitle)")
            return
        }
        
        // Initialize player item and player
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        player?.play()
        isPlaying = true
        currentSongTitle = songTitle
        
        updateNowPlayingInfo(songTitle: songTitle)
        
        setupRemoteTransportControls()
        
        startObservingCurrentTime()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
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
            self?.removeTimeObserver()
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
    
    func nextPlaylist() {
        if currentPlaylistIndex < playlist.count - 1 {
            removeTimeObserver()
            currentPlaylistIndex += 1
            startPlayback(songTitle: playlist[currentPlaylistIndex].name)
            setCancelabel()
        }
    }

    func previousPlaylist() {
        if currentPlaylistIndex > 0 {
            removeTimeObserver()
            currentPlaylistIndex -= 1
            startPlayback(songTitle: playlist[currentPlaylistIndex].name)
            setCancelabel()
        }
    }
    
    private func setCancelabel() {
        cancellable = currentPlaylistIndexPublisher.sink { newIndex in
            print("Current playlist index changed to: \(newIndex)")
        }
    }
}

extension AVManager {
    private func setupRemoteTransportControls() {
        guard !commandHandlersSetup else { return }
                
        commandHandlersSetup = true
        
        nextPlaylistCommand()
        previousPlaylistCommand()
        pausePlaylistCommand()
        playPlaylistCommand()
    }
    
    private func getAppIcon() -> UIImage? {
        if let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIconDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIconDictionary["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
    private func updateNowPlayingInfo(songTitle: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songTitle
        let artwork = MPMediaItemArtwork(boundsSize: getAppIcon()!.size) { size in
            return self.getAppIcon()!
        }
        

        if let playerItem = self.playerItem {
            let duration = CMTimeGetSeconds(playerItem.asset.duration)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(playerItem.currentTime())
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.isPlaying ? 1.0 : 0.0
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func nextPlaylistCommand() {
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.removeTarget(nil)
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.nextPlaylist()
            
            return .success
        }
    }
    
    private func previousPlaylistCommand() {
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.removeTarget(nil)
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.previousPlaylist()
            
            return .success
        }
    }
    
    private func pausePlaylistCommand() {
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.removeTarget(nil)
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.pausePlayback()
            return .success
        }
    }
    
    private func playPlaylistCommand() {
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.removeTarget(nil)
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.resumePlayback()
            return .success
        }
    }
    
    @objc
    private func playerDidFinishPlaying(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        nextPlaylist()
    }
    
    private func startObservingCurrentTime() {
        guard let player = player else { return }
        
        // Set up periodic time observer
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTimeInSeconds = CMTimeGetSeconds(time)
        }
    }
    
    private func removeTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}

extension AVManager {
    // MARK: - Fade-In and Fade-Out Methods
    
    func pausePlayback() {
        player?.pause()
        self.isPlaying = false
        updateNowPlayingInfo(songTitle: currentSongTitle ?? "")
    }
    
    func resumePlayback() {
        player?.play()
        self.isPlaying = true
        updateNowPlayingInfo(songTitle: currentSongTitle ?? "")
    }
}
