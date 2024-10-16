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

    enum VolumeLevel {
        case none
        case low // 50% volume
        case high // 100% volume
    }
    
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

            print("Audio session berhasil diatur.")
        } catch {
            print("Gagal mengatur sesi audio: \(error.localizedDescription)")
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
            if audioVideoManager.isPlaying {
                audioVideoManager.fadeToVolume(targetVolume: 0.0, duration: 1.0) {
                    self.stopPlayback()
                }
            }
            currentVolumeLevel = .none
            lastTargetVolume = nil
            return
        }

        if audioVideoManager.currentSongTitle != "" || audioVideoManager.currentSongTitle != "none" && !audioVideoManager.isPlaying {
            audioVideoManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
            lastTargetVolume = targetVolume
            currentVolumeLevel = newVolumeLevel
            startPlayback(song: fetchCurrentSong())
        } else {
            if lastTargetVolume != targetVolume {
                audioVideoManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
                lastTargetVolume = targetVolume
                currentVolumeLevel = newVolumeLevel
                audioVideoManager.isPlaying = false
            }
        }

    }
    
    func updateDistance(_ distance: Double) {
        
    }
    
    func fetchResources() {
        if self.isFindBeacon {
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
    }
    
    func getClosestBeacon(_ distance: Double) {
        if !self.isFindBeacon {
            if let closestBeacon = beaconScanner.closestBeacon, distance >= 0 {
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
        if let closestBeacon = beaconScanner.closestBeacon, distance >= 0 {
            let identifier = beaconScanner.beaconIdentifier(for: closestBeacon)
            proximityText = "Closest Beacon: \(identifier)"
            print("Beacon detected: \(identifier), Estimated Distance: \(distance) meters")

            print("ini playlist", audioVideoManager.playlist)
            self.isFindBeacon = true
            
            if self.isFindBeacon {
                let collections = fetchCollectionByBeaconId(id: identifier)
                if !collections.isEmpty {
                    for collection in collections {
                        
                        let playlist = fetchPlaylistByCollectionId(id: collection.uuid)
                        if !playlist.isEmpty {
                            adjustAudioForDistance(distance: distance)
                            audioVideoManager.playlist = playlist
                        }
                    }
                }
            }
            
            if distance <= 2.0{
                // Reset lostBeaconCount since we are within 2 meters
                lostBeaconCount = 0
//                self.isFirst = false
            } else {
                // Distance is greater than 2 meters
                lostBeaconCount += 1
                self.isFindBeacon = false
                print("Distance greater than 2 meters. Lost count: \(lostBeaconCount)")
                if lostBeaconCount >= maxLostBeaconCount {
                    proximityText = "Beacon is too far"
                    print("Beacon too far after \(maxLostBeaconCount) attempts")
                    audioVideoManager.stopPlayback()
                    lastTargetVolume = nil
                    currentVolumeLevel = .none
                }
                // Else, keep current playback state
            }
        } else {
            // Beacon not detected or distance invalid
            self.isFindBeacon = false
            lostBeaconCount += 1
            print("Beacon not detected or invalid distance. Lost count: \(lostBeaconCount)")
            if lostBeaconCount >= maxLostBeaconCount {
                proximityText = "No Beacon Detected"
                print("No closest beacon found after \(maxLostBeaconCount) attempts")
                audioVideoManager.stopPlayback()
                lastTargetVolume = nil
                currentVolumeLevel = .none
            }
            // Else, keep current playback state
        }
    }
}
