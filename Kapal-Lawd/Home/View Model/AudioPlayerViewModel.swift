//
//  AudioPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 19/09/24.
//

import AVFoundation
import SwiftUI
import Combine

class AudioPlayerViewModel: ObservableObject {
    @Published var currentSongTitle: String?
    private var collectionRepo = JSONCollectionsRepository()
    private var playlistRepo = JSONPlaylistRepository()
    
    @Published var audioVideoManager = AVManager.shared
    @Published var backgroundSoundManager = BackgroundSoundManager.shared
    @Published var microInteractionManager = MicroInteractionManager.shared
    
    @Published var beaconScanner = IBeaconDetector()
    @Published var proximityText: String = "No Beacon Detected"
    private var lastTargetVolume: Float? = nil
    private var currentVolumeLevel: VolumeLevel = .none
    private var lostBeaconCount: Int = 0
    private let maxLostBeaconCount = 5 // Threshold for consecutive losses
    @Published var isFindBeacon = false
    @Published var isBeaconFar = true
    
    private var cancellables = Set<AnyCancellable>()
    @Published var backgroundSound: String = ""
    @Published var collections: [Collections] = []
    
    enum VolumeLevel: Int {
        case none = 0
        case level1 = 1 // 20% volume
        case level2 = 2 // 40% volume
        case level3 = 3 // 60% volume
        case level4 = 4 // 80% volume
        case level5 = 5 // 100% volume
    }
    
    init() {
        // Observe the averageRSSI from beaconScanner
        beaconScanner.$averageRSSI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rssi in
                self?.handleRSSIChange(rssi)
            }
            .store(in: &cancellables)
    }
    
    func fetchCollectionByBeaconId(id: String) -> [Collections] {
        for beacon in beaconScanner.beacons {
            if beacon.uuid.lowercased() == beaconScanner.closestBeacon?.uuid.uuidString.lowercased() {
                self.backgroundSound = beacon.backgroundSound
            }
        }
        
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
}

extension AudioPlayerViewModel {
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
    
    func startBackgroundSound(song: String) {
        backgroundSoundManager.startPlayback(songTitle: song)
    }
    
    func stopBackground() {
        backgroundSoundManager.stopPlayback()
    }
    
    func interactionSound(song: String) {
        microInteractionManager.startPlayback(songTitle: song)
    }
    
    func stopInteractionSound() {
        microInteractionManager.stopPlayback()
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
    
    func adjustAudioForRSSI(rssi: Double, minRssi: Double, maxRssi: Double) {
        let levels = 5
        let hysteresis = 2.0 // Adjust as needed
        
        // Calculate the delta between levels
        let delta = (maxRssi - minRssi) / Double(levels)
        
        // Create dynamic thresholds
        var thresholds: [(enter: Double, exit: Double, volumeLevel: VolumeLevel, volume: Float)] = []
        
        for i in 0..<levels {
            let enter = maxRssi - Double(i) * delta
            let exit = enter - hysteresis
            let volumeLevel = VolumeLevel(rawValue: levels - i) ?? .none
            let volume = Float(volumeLevel.rawValue) / Float(levels)
            thresholds.append((enter: enter, exit: exit, volumeLevel: volumeLevel, volume: volume))
        }
        
        var targetVolume: Float = 0.0
        var newVolumeLevel: VolumeLevel = .none
        
        for threshold in thresholds {
            if currentVolumeLevel == threshold.volumeLevel {
                // Currently in this volume level, check exit condition
                if rssi < threshold.exit {
                    continue
                } else {
                    newVolumeLevel = threshold.volumeLevel
                    targetVolume = threshold.volume
                    break
                }
            } else {
                // Not in this volume level, check enter condition
                if rssi >= threshold.enter {
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
        
        print("RSSI: \(rssi), Target Volume: \(targetVolume), Current Volume Level: \(currentVolumeLevel), New Volume Level: \(newVolumeLevel)")
        
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
        
        let songTitle = fetchCurrentSong()
        
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
    
    func handleRSSIChange(_ rssi: Double) {
        if let closestBeacon = beaconScanner.closestBeacon, rssi > -100.0 {
            let identifier = beaconScanner.beaconIdentifier(for: closestBeacon)
            
            // Find the corresponding Beacons object
            if let beaconInfo = beaconScanner.beacons.first(where: { $0.uuid.lowercased() == closestBeacon.uuid.uuidString.lowercased() }) {
                
                let minRssi = beaconInfo.minRssi
                let maxRssi = beaconInfo.maxRssi
                
                proximityText = "Closest Beacon Found"
                print("Beacon detected: \(identifier), Average RSSI: \(rssi) dBm")
                
                if rssi >= minRssi {
                    // Reset lostBeaconCount since we are within range
                    self.isFindBeacon = true
                    self.isBeaconFar = false
                    self.lostBeaconCount = 0
                    adjustAudioForRSSI(rssi: rssi, minRssi: minRssi, maxRssi: maxRssi)
                } else {
                    // RSSI is lower than minRssi
                    self.lostBeaconCount += 1
                    print("RSSI lower than minRssi. Lost count: \(self.lostBeaconCount)")
                    if self.lostBeaconCount >= self.maxLostBeaconCount {
                        proximityText = "Beacon is too far"
                        self.isFindBeacon = false
                        self.isBeaconFar = true
                        stopPlayback()
                        stopBackground()
                        print("Beacon too far after \(maxLostBeaconCount) attempts")
                        // Reset variables
                        lastTargetVolume = nil
                        currentVolumeLevel = .none
                    }
                }
            } else {
                print("No matching beacon info found.")
            }
        } else {
            // No beacon detected
            self.lostBeaconCount += 1
            print("Beacon not detected or invalid RSSI. Lost count: \(self.lostBeaconCount)")
            if self.lostBeaconCount >= self.maxLostBeaconCount {
                self.isFindBeacon = false
                self.isBeaconFar = true
                proximityText = "No Beacon Detected"
                stopPlayback()
                stopBackground()
                print("No closest beacon found after \(maxLostBeaconCount) attempts")
                // Reset variables
                lastTargetVolume = nil
                currentVolumeLevel = .none
            }
        }
    }
}
