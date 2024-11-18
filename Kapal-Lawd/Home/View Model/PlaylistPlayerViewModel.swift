//
//  PlaylistPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 01/11/24.
//

import AVFoundation

class PlaylistPlayerViewModel: ObservableObject {
    @Published var currentSongTitle: String?
    @Published var playlistPlayerManager: AVManager = AVManager.shared
    
    func fetchCurrentSong() -> String {
        currentSongTitle = playlistPlayerManager.currentSongTitle
        return currentSongTitle ?? "none"
    }
    
    func previousPlaylist() {
        playlistPlayerManager.previousPlaylist()
    }
    
    func nextPlaylist() {
        playlistPlayerManager.nextPlaylist()
    }
    
    func startPlayback(song: String, url: String) {
        playlistPlayerManager.startPlayback(songTitle: song, url: url)
    }
    
    func stopPlayback() {
        playlistPlayerManager.stopPlayback()
    }
    
    func pausePlayback() {
        playlistPlayerManager.pausePlayback()
    }
    
    func resumePlayback() {
        playlistPlayerManager.resumePlayback()
    }
    
    func resetAsset() {
        playlistPlayerManager.reset()
    }
    
    func seekBackward() {
        playlistPlayerManager.seekBackward(seconds: 15)
    }
    
    func seekForward() {
        playlistPlayerManager.seekForward(seconds: 15)
    }
}
