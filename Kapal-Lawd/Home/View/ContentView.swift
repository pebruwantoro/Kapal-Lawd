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

    enum VolumeLevel: Int {
        case none = 0
        case level1 = 1 // 20% volume
        case level2 = 2 // 40% volume
        case level3 = 3 // 60% volume
        case level4 = 4 // 80% volume
        case level5 = 5 // 100% volume
    }

    // Distance thresholds with hysteresis
    private let thresholds: [(enter: Double, exit: Double, volumeLevel: VolumeLevel, volume: Float)] = [
        (enter: 0.0, exit: 0.5, volumeLevel: .level5, volume: 1.0),  // Level 5
        (enter: 0.4, exit: 0.9, volumeLevel: .level4, volume: 0.8),  // Level 4
        (enter: 0.8, exit: 1.3, volumeLevel: .level3, volume: 0.6),  // Level 3
        (enter: 1.2, exit: 1.7, volumeLevel: .level2, volume: 0.4),  // Level 2
        (enter: 1.6, exit: 2.1, volumeLevel: .level1, volume: 0.2)   // Level 1
    ]

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
        var targetVolume: Float = 0.0
        var newVolumeLevel: VolumeLevel = .none

        // Determine the new volume level based on distance and hysteresis
        for threshold in thresholds {
            if currentVolumeLevel == threshold.volumeLevel {
                // Currently in this volume level, check exit condition
                if distance > threshold.exit {
                    continue
                } else {
                    newVolumeLevel = threshold.volumeLevel
                    targetVolume = threshold.volume
                    break
                }
            } else {
                // Not in this volume level, check enter condition
                if distance <= threshold.enter {
                    newVolumeLevel = threshold.volumeLevel
                    targetVolume = threshold.volume
                    break
                }
            }
        }

        if newVolumeLevel == .none {
            targetVolume = 0.0
        }

        if newVolumeLevel == currentVolumeLevel {
            // No change in volume level
            return
        }

        print("Distance: \(distance), Target Volume: \(targetVolume), Current Volume Level: \(currentVolumeLevel), New Volume Level: \(newVolumeLevel)")

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
