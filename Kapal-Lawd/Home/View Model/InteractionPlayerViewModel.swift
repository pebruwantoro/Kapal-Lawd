//
//  InteractionPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 01/11/24.
//

import AVFoundation

class InteractionPlayerViewModel: ObservableObject {
    
    @Published var interactionSoundManager: MicroInteractionManager = MicroInteractionManager.shared
    
    func startInteractionSound(song: String) {
        interactionSoundManager.startPlayback(songTitle: song)
    }
    
    func stopInteraction(){
        interactionSoundManager.stopPlayback()
    }
}
