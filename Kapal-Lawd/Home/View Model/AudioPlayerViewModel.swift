//
//  AudioPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 19/09/24.
//

import AVFoundation
import SwiftUI

class AudioPlayerViewModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    
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
}

