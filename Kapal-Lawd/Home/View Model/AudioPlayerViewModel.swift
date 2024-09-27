//
//  AudioPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 19/09/24.
//

import Foundation
import AVKit
import Combine

class AudioPlayerViewModel: ObservableObject {
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    @Published var isPlaying = false
    @Published var currentSongTitle: String?
    private var beaconLocalRepo = JSONBeaconsRepository()

    func startPlayback(songTitle: String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        self.playerItem = playerItem
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.play()
        self.isPlaying = true
        self.currentSongTitle = songTitle
    }

    func pausePlayback() {
        self.player?.pause()
        self.isPlaying = false
    }

    func resumePlayback() {
        self.player?.play()
        self.isPlaying = true
    }

    func stopPlayback() {
        self.player?.pause()
        self.player?.seek(to: CMTime.zero)
        self.isPlaying = false
    }
    
    func fetchDataBeacon() -> [Beacons]{
        let result = beaconLocalRepo.fetchListBeacons()
        let errorHandler = result.1
        if let errorHandler = errorHandler {
            print("error")
        }
        return result.0
    }
}
