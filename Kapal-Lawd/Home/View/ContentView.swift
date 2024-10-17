//
//  ContentView.swift
//  Kapal Lawd
//
//  Created by Doni Pebruwantoro on 18/09/24.
//

import SwiftUI
import AVFoundation
import Combine

struct ContentView: View {
    @StateObject var beaconScanner = IBeaconDetector()
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()
    @State private var proximityText: String = "No Beacon Detected"
    @StateObject private var avManager = AVManager.shared
    @State private var lastTargetVolume: Float? = nil
    @State private var currentVolumeLevel: VolumeLevel = .none
    @State private var lostBeaconCount: Int = 0
    private let maxLostBeaconCount = 5 // Threshold for consecutive losses

    enum VolumeLevel: Int {
        case none = 0
        case level1 = 1 // 20% volume
        case level2 = 2 // 40% volume
        case level3 = 3 // 60% volume
        case level4 = 4 // 80% volume
        case level5 = 5 // 100% volume
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(audioPlayerViewModel.proximityText)
                .padding()
                .font(.headline)
                .onReceive(audioPlayerViewModel.beaconScanner.$estimatedDistance) { distance in
                    print("distance:", distance)
                    audioPlayerViewModel.handleEstimatedDistanceChange(distance)
                }
                .onReceive(audioPlayerViewModel.$isFindBeacon) { isFindBeacon in
                    print("find my beacon: ", isFindBeacon)
//                    audioPlayerViewModel.fetchResources()
                }
            
            if audioPlayerViewModel.beaconScanner.estimatedDistance >= 0 {
                Text(String(format: "Estimated Distance: %.2f meters", audioPlayerViewModel.beaconScanner.estimatedDistance))
                    .font(.subheadline)
            } else {
                Text("Estimating distance...")
                    .font(.subheadline)
            }
            
            if audioPlayerViewModel.isFindBeacon {
                Text(String(format: "Now Playing: %@", audioPlayerViewModel.currentSongTitle ?? "none"))
                
                // Audio Player Controls
                HStack {
                    Button("Previous", action: {
                        audioPlayerViewModel.previousPlaylist()
                        audioPlayerViewModel.adjustAudioForDistance(distance: audioPlayerViewModel.beaconScanner.estimatedDistance)
                    })
                    
                    if audioPlayerViewModel.audioVideoManager.isPlaying {
                        Button("Pause", action: {
                            audioPlayerViewModel.pausePlayback()
                        })
                    } else {
                        Button("Play", action: {
                            audioPlayerViewModel.resumePlayback()
                        })
                    }
                    
                    Button("Next", action: {
                        audioPlayerViewModel.nextPlaylist()
                        audioPlayerViewModel.adjustAudioForDistance(distance: audioPlayerViewModel.beaconScanner.estimatedDistance)
                    })
                }
                .padding()
            }
            // Else, keep current playback state
        }
        .onAppear {
            audioPlayerViewModel.configureAudioSession()
        }
    }
}
