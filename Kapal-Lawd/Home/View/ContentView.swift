//
//  ContentView.swift
//  Kapal Lawd
//
//  Created by Doni Pebruwantoro on 18/09/24.
//


import SwiftUI
import AVFoundation
import CoreLocation

struct ContentView: View {
    @StateObject var beaconScanner = IBeaconDetector()
    @State private var proximityText: String = "No Beacon Detected"
    @StateObject private var avManager = AVManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text(proximityText)
                .padding()
                .font(.headline)
                .onReceive(beaconScanner.$closestBeacon) { beacon in
                    handleClosestBeaconChange(beacon)
                }

            if beaconScanner.estimatedDistance >= 0 {
                Text(String(format: "Estimated Distance: %.2f meters", beaconScanner.estimatedDistance))
                    .font(.subheadline)
            } else {
                Text("Estimating distance...")
                    .font(.subheadline)
            }

            Text("Now Playing: \(avManager.currentSongTitle ?? "None")")
                .font(.subheadline)

            // Audio Player Controls
            HStack {
                Button(action: {
                    if avManager.isPlaying {
                        avManager.pausePlayback()
                    } else if let songTitle = avManager.currentSongTitle {
                        avManager.resumePlayback()
                    }
                }) {
                    Text(avManager.isPlaying ? "Pause" : "Play")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    // Handle changes in the closest beacon
    private func handleClosestBeaconChange(_ beacon: CLBeacon?) {
        if let beacon = beacon {
            let identifier = beaconScanner.beaconIdentifier(for: beacon)
            proximityText = "Closest Beacon: \(identifier)"
            if let songTitle = beaconScanner.getAudioFileName(for: identifier) {
                startAudioIfNeeded(songTitle: songTitle)
            } else {
                avManager.stopPlayback()
            }
        } else {
            proximityText = "No Beacon Detected"
            avManager.stopPlayback()
        }
    }

    // Start audio playback if not already playing
    private func startAudioIfNeeded(songTitle: String) {
        if avManager.currentSongTitle != songTitle {
            avManager.stopPlayback()
            avManager.startPlayback(songTitle: songTitle)
        } else if !avManager.isPlaying {
            avManager.resumePlayback()
        }
    }
}
