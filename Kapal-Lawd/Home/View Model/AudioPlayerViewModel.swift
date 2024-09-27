//
//  AudioPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 19/09/24.
//

import AVFoundation
import SwiftUI

class AudioPlayerViewModel: ObservableObject {
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    @Published var isPlaying = false
    @Published var currentSongTitle: String?
    private var beaconLocalRepo = JSONBeaconsRepository()

    private var audioPlayer: AVAudioPlayer?
    
    func startPlayback(songTitle: String) {
        if let path = Bundle.main.path(forResource: songTitle, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                isPlaying = true
                print("Memulai playback \(songTitle)")
            } catch {
                print("Error memulai playback: \(error.localizedDescription)")
            }
        }
    }
    
    func stopPlayback() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            isPlaying = false
            print("Menghentikan playback")
        }
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

