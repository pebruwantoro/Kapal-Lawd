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
    private var collectionRepo = JSONCollectionsRepository()
    private var playlistRepo = JSONPlaylistRepository()

    @Published var audioVideoManager = AVManager.shared
        
    @Published var beaconScanner = IBeaconDetector()
    @Published var proximityText: String = "No Beacon Detected"
    @State private var lastTargetVolume: Float? = nil
    @State private var currentVolumeLevel: VolumeLevel = .none
    @State private var lostBeaconCount: Int = 0
    private let maxLostBeaconCount = 5 // Threshold for consecutive losses
    @Published var isFindBeacon = false

    enum VolumeLevel: Int {
        case none = 0
        case level1 = 1 // 20% volume
        case level2 = 2 // 40% volume
        case level3 = 3 // 60% volume
        case level4 = 4 // 80% volume
        case level5 = 5 // 100% volume
    }
    
    private let thresholds: [(enter: Double, exit: Double, volumeLevel: VolumeLevel, volume: Float)] = [
        (enter: 0.0, exit: 0.5, volumeLevel: .level5, volume: 1.0),  // Level 5
        (enter: 0.4, exit: 0.9, volumeLevel: .level4, volume: 0.8),  // Level 4
        (enter: 0.8, exit: 1.3, volumeLevel: .level3, volume: 0.6),  // Level 3
        (enter: 1.2, exit: 1.7, volumeLevel: .level2, volume: 0.4),  // Level 2
        (enter: 1.6, exit: 2.1, volumeLevel: .level1, volume: 0.2)   // Level 1
    ]
    
    func fetchCollectionByBeaconId(id: String) -> [Collections] {
        print("beacon id", id)
        let result = collectionRepo.fetchListCollectionsByBeaconId(req: CollectionsRequest(beaconId: id))
        let errorHandler = result.1
        if let errorHandler = errorHandler {
            print("error: \(errorHandler)")
        }
        return result.0
    }
    
    func fetchPlaylistByCollectionId(id: String) -> [Playlist] {
        let result = playlistRepo.fetchPlaylistByCollectionId(req: PlaylistRequest(collectionId: id))
        let errorHandler = result.1
        if let errorHandler = errorHandler {
            print("error: \(errorHandler)")
        }
        
        return result.0
    }
    
    internal func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(.playback, mode: .default)

            try session.setActive(true)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

extension AudioPlayerViewModel {
    func isAudioPlaying() -> Bool {
        return audioVideoManager.isPlaying
    }
    
    func fetchCurrentSong() -> String {
        currentSongTitle = audioVideoManager.currentSongTitle
        return currentSongTitle ?? "none"
    }
    
    func previousPlaylist() {
        audioVideoManager.previousPlaylist()
    }
    
    func nextPlaylist() {
        audioVideoManager.nextPlaylist()
    }
    
    func startPlayback(song: String) {
        audioVideoManager.startPlayback(songTitle: song)
    }
    
    func stopPlayback() {
        audioVideoManager.stopPlayback()
    }
    
    func pausePlayback() {
        audioVideoManager.pausePlayback()
    }
    
    func resumePlayback() {
        audioVideoManager.resumePlayback()
    }
    
    func adjustAudioForDistance(distance: Double) {
        var targetVolume: Float = 0.0
        var newVolumeLevel: VolumeLevel = .none
        let songTitle = fetchCurrentSong()

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
            if audioVideoManager.isPlaying {
                audioVideoManager.fadeToVolume(targetVolume: 0.0, duration: 1.0) {
                    self.stopPlayback()
                }
            }
            currentVolumeLevel = .none
            lastTargetVolume = nil
            return
        }

        if audioVideoManager.currentSongTitle != songTitle || !audioVideoManager.isPlaying {
            // Start new playback
            self.stopPlayback()
            self.currentSongTitle = songTitle
            self.startPlayback(song: songTitle)
            audioVideoManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
            lastTargetVolume = targetVolume
            currentVolumeLevel = newVolumeLevel
        } else {
            if lastTargetVolume != targetVolume {
                audioVideoManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
                lastTargetVolume = targetVolume
                currentVolumeLevel = newVolumeLevel
            }
        }
    }
        
    func fetchResources() {
        let collections = fetchCollectionByBeaconId(id: beaconScanner.beaconIdentifier(for: beaconScanner.closestBeacon!))
        if !collections.isEmpty {
            for collection in collections {
                
                let playlist = fetchPlaylistByCollectionId(id: collection.uuid)
                if !playlist.isEmpty {
                    adjustAudioForDistance(distance: beaconScanner.estimatedDistance)
                    audioVideoManager.playlist = playlist
                }
            }
        }
    }
    
    func getClosestBeacon(_ distance: Double) {
        if !self.isFindBeacon {
            
            if let closestBeacon = beaconScanner.closestBeacon {
                let identifier = beaconScanner.beaconIdentifier(for: closestBeacon)
                self.proximityText = "Closest Beacon: \(identifier)"
                self.isFindBeacon = true
            }
        } else {
            if distance > 0.5 {
                self.isFindBeacon = false
                beaconScanner.closestBeacon = nil
                audioVideoManager.playlist = []
                self.stopPlayback()
                self.lastTargetVolume = nil
                self.currentVolumeLevel = .none
                audioVideoManager.isPlaying = false
            }
        }
    }
    
    func handleEstimatedDistanceChange(_ distance: Double) {
        if let closestBeacon = beaconScanner.closestBeacon {
            let identifier = beaconScanner.beaconIdentifier(for: closestBeacon)
            proximityText = "Closest Beacon: \(identifier)"
            print("Beacon detected: \(identifier), Estimated Distance: \(distance) meters")

            if distance <= 2.0 {
                // Reset lostBeaconCount since we are within 2 meters
                lostBeaconCount = 0
                adjustAudioForDistance(distance: distance)
//                self.fetchResources()
//                if let songTitle = beaconScanner.getAudioFileName(for: identifier) {
//                    print("Song mapped to beacon: \(songTitle)")
//                    adjustAudioForDistance(distance: distance, songTitle: songTitle)
//                } else {
//                    print("No song mapped for beacon: \(identifier)")
//                    avManager.stopPlayback()
//                    lastTargetVolume = nil
//                    currentVolumeLevel = .none
//                }
            } else {
                // Distance is greater than 2 meters
                lostBeaconCount += 1
                print("Distance greater than 2 meters. Lost count: \(lostBeaconCount)")
                if lostBeaconCount >= maxLostBeaconCount {
                    proximityText = "Beacon is too far"
                    print("Beacon too far after \(maxLostBeaconCount) attempts")
                    self.stopPlayback()
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
                self.stopPlayback()
                lastTargetVolume = nil
                currentVolumeLevel = .none
            }
        }
    }
}
