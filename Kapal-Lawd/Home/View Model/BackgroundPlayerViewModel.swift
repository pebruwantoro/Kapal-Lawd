//
//  BackgroundPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 01/11/24.
//

import AVFoundation

class BackgroundPlayerViewModel: ObservableObject {
    
    @Published var backgroundSoundManager: BackgroundSoundManager = BackgroundSoundManager.shared
    
    func startBackgroundSound(song: String) {
        backgroundSoundManager.startPlayback(songTitle: song)
    }
    
    func stopBackground(){
        backgroundSoundManager.stopPlayback()
    }
}
