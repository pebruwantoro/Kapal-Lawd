//
//  ContentView.swift
//  Kapal Lawd
//
//  Created by Doni Pebruwantoro on 18/09/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var beaconScanner = IBeaconDetector()
    @State private var proximityText: String = "No Beacon Detected"
    @StateObject private var avManager = AVManager.shared
    @State private var lastTargetVolume: Float? = nil
    @State private var currentVolumeLevel: VolumeLevel = .none
    @State private var lostBeaconCount: Int = 0
    private let maxLostBeaconCount = 5 // Threshold for consecutive losses

    enum VolumeLevel {
        case none
        case low // 50% volume
        case high // 100% volume
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(proximityText)
                .padding()
                .font(.headline)
                .onReceive(beaconScanner.$estimatedDistance) { distance in
                    handleEstimatedDistanceChange(distance)
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
                        avManager.startPlayback(songTitle: songTitle)
                    }
                }) {
                    Text(avManager.isPlaying ? "Pause" : "Play")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Test Play Button
                Button(action: {
                    avManager.startPlayback(songTitle: "dreams")
                    avManager.fadeToVolume(targetVolume: 1.0, duration: 1.0)
                }) {
                    Text("Test Play")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .onAppear {
            configureAudioSession()
        }
    }

    // Handle changes in the estimated distance
    private func handleEstimatedDistanceChange(_ distance: Double) {
        if let closestBeacon = beaconScanner.closestBeacon, distance >= 0 {
            let identifier = beaconScanner.beaconIdentifier(for: closestBeacon)
            proximityText = "Closest Beacon: \(identifier)"
            print("Beacon detected: \(identifier), Estimated Distance: \(distance) meters")

            if distance <= 2.0 {
                // Reset lostBeaconCount since we are within 2 meters
                lostBeaconCount = 0
                if let songTitle = beaconScanner.getAudioFileName(for: identifier) {
                    print("Song mapped to beacon: \(songTitle)")
                    adjustAudioForDistance(distance: distance, songTitle: songTitle)
                } else {
                    print("No song mapped for beacon: \(identifier)")
                    avManager.stopPlayback()
                    lastTargetVolume = nil
                    currentVolumeLevel = .none
                }
            } else {
                // Distance is greater than 2 meters
                lostBeaconCount += 1
                print("Distance greater than 2 meters. Lost count: \(lostBeaconCount)")
                if lostBeaconCount >= maxLostBeaconCount {
                    proximityText = "Beacon is too far"
                    print("Beacon too far after \(maxLostBeaconCount) attempts")
                    avManager.stopPlayback()
                    lastTargetVolume = nil
                    currentVolumeLevel = .none
                }
                // Else, keep current playback state
            }
        } else {
            // Beacon not detected or distance invalid
            lostBeaconCount += 1
            print("Beacon not detected or invalid distance. Lost count: \(lostBeaconCount)")
            if lostBeaconCount >= maxLostBeaconCount {
                proximityText = "No Beacon Detected"
                print("No closest beacon found after \(maxLostBeaconCount) attempts")
                avManager.stopPlayback()
                lastTargetVolume = nil
                currentVolumeLevel = .none
            }
            // Else, keep current playback state
        }
    }

    // Adjust audio playback based on distance
    private func adjustAudioForDistance(distance: Double, songTitle: String) {
        let targetVolume: Float
        var newVolumeLevel: VolumeLevel = currentVolumeLevel

        switch currentVolumeLevel {
        case .none:
            if distance <= 2.0 {
                newVolumeLevel = distance <= 1.0 ? .high : .low
                targetVolume = newVolumeLevel == .high ? 1.0 : 0.5
            } else {
                targetVolume = 0.0
            }
        case .low:
            if distance <= 1.0 {
                newVolumeLevel = .high
                targetVolume = 1.0
            } else if distance > 2.1 {
                newVolumeLevel = .none
                targetVolume = 0.0
            } else {
                newVolumeLevel = .low
                targetVolume = 0.5
            }
        case .high:
            if distance > 1.1 {
                newVolumeLevel = .low
                targetVolume = 0.5
            } else {
                newVolumeLevel = .high
                targetVolume = 1.0
            }
        }

        print("Distance: \(distance), Target Volume: \(targetVolume), Current Volume Level: \(currentVolumeLevel)")

        if targetVolume == 0.0 {
            if avManager.isPlaying {
                avManager.fadeToVolume(targetVolume: 0.0, duration: 1.0) { [weak avManager] in
                    avManager?.stopPlayback()
                }
            }
            currentVolumeLevel = .none
            lastTargetVolume = nil
            return
        }

        if avManager.currentSongTitle != songTitle || !avManager.isPlaying {
            // Start new playback
            avManager.stopPlayback()
            avManager.currentSongTitle = songTitle
            avManager.startPlayback(songTitle: songTitle)
            avManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
            lastTargetVolume = targetVolume
            currentVolumeLevel = newVolumeLevel
        } else {
            if lastTargetVolume != targetVolume {
                avManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
                lastTargetVolume = targetVolume
                currentVolumeLevel = newVolumeLevel
            }
        }
    }

    // Configure audio session for background playback
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            // Use playback category to play audio in the background
            try session.setCategory(.playback, mode: .default)

            // Activate the audio session
            try session.setActive(true)

            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}

