//
//  ViewController.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 18/09/24.
//

import CoreLocation
import Combine
import SwiftUI

class IBeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var beaconRepo = JSONBeaconsRepository()
    private var beaconData: Beacons?
    private var lastTargetVolume: Float? = nil
    private var currentVolumeLevel: VolumeLevel = .none
    var dataBeacons: [Beacons] = []
    var beaconBLE: [String: CLBeacon] = [:]
    @ObservedObject private var audioPlayerManager = AVManager.shared
    @Published var isFindBeacon = false
    @Published var isBeaconFar = true
    @Published var isBeaconChange = false
    @Published var backgroundSound: String = ""
    @Published var detectedBeacons: [CLBeacon] = []
    @Published var closestBeacon: CLBeacon?
    @Published var isSessionActive: Bool = false
    @Published var currentSongTitle: String?
    @Published var currentBeaconId: String?
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true

        Task {
            await self.fetchBeacons()
        }
    }
    
    private func fetchBeacons() async {
        do {
            let fetchedBeacons = try await beaconRepo.fetchListBeacons()
            DispatchQueue.main.async {
                self.dataBeacons = fetchedBeacons
                self.startMonitoring()
            }
        } catch {
            print("Error fetching beacons: \(error.localizedDescription)")
            // Handle error appropriately (e.g., show an alert or retry)
        }
    }

    func startMonitoring() {
        guard let locationManager = self.locationManager else { return }
        guard !self.dataBeacons.isEmpty else { return }
        
        for beacon in self.dataBeacons {
            if let uuid = UUID(uuidString: beacon.uuid) {
                let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
                beaconRegion.notifyEntryStateOnDisplay = true
                locationManager.startMonitoring(for: beaconRegion)
                locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
            }
        }
        
        self.isSessionActive = true
        locationManager.startUpdatingLocation()
    }
    
    func stopMonitoring() {
        for beacon in self.dataBeacons {
            if let uuid = UUID(uuidString: beacon.uuid) {
                let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
                locationManager?.stopMonitoring(for: beaconRegion)
                locationManager?.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
            }
        }
        
        self.isSessionActive = false
    }

    // Helper function to create a unique identifier for a beacon
    func beaconIdentifier(for beacon: CLBeacon) -> String {
        // Modify as needed to include major and minor if necessary
        return "\(beacon.uuid.uuidString.lowercased())"
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        DispatchQueue.main.async {
            self.dataBeacons.removeAll { $0.uuid == region.identifier }
            if self.closestBeacon?.uuid.uuidString == region.identifier {
                if let beaconRegion = region as? CLBeaconRegion {
                    self.locationManager?.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
                }
            }
            self.makeDisactive()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Keep empty; sufficient to keep the app running in the background
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if isSessionActive {
                delay(1) {
                    self.startMonitoring()
                }
            }
        default:
            if isSessionActive {
                stopMonitoring()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        delay(2) {
            for beacon in beacons {
                if let dataBeacon = self.dataBeacons.first(where: { $0.uuid == beacon.uuid.uuidString.lowercased()}) {
                    self.beaconData = dataBeacon
                    if beacon.rssi != 0 && Double(beacon.rssi) >= dataBeacon.maxRssi {
                        self.beaconBLE[beacon.uuid.uuidString.lowercased()] = beacon
                    } else {
                        self.beaconBLE[beacon.uuid.uuidString.lowercased()] = beacon
                    }
                }
            }
            
            if let nearestBeacon = self.beaconBLE.values.max(by: { $0.rssi < $1.rssi }) {
                if self.currentBeaconId != nearestBeacon.uuid.uuidString {
                    self.isBeaconChange = true
                    self.currentBeaconId = nearestBeacon.uuid.uuidString
                    self.closestBeacon = nearestBeacon
                } else {
                    self.isBeaconChange = false
                    self.currentBeaconId = nearestBeacon.uuid.uuidString
                    self.closestBeacon = nearestBeacon
                }
                
                self.makeActive()
                
                self.adjustAudioForRSSI(rssi: Double(nearestBeacon.rssi), maxRssi: self.beaconData!.maxRssi, minRssi: self.beaconData!.minRssi)
            }
        }
    }
    
    private func makeActive() {
        self.isBeaconFar = false
        self.isFindBeacon = true
    }
    
    private func makeDisactive() {
        self.isBeaconFar = true
        self.isFindBeacon = false
    }
    
    func adjustAudioForRSSI(rssi: Double, maxRssi: Double, minRssi: Double) {
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
        let songTitle = audioPlayerManager.currentSongTitle
        
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
            if audioPlayerManager.isPlaying {
                audioPlayerManager.fadeToVolume(targetVolume: 0.0, duration: 1.0) {
                    self.audioPlayerManager.stopPlayback()
                }
            }
            currentVolumeLevel = .none
            lastTargetVolume = nil
            return
        }
        
        if audioPlayerManager.currentSongTitle != songTitle || !audioPlayerManager.isPlaying {
            // Start new playback
            audioPlayerManager.stopPlayback()
            audioPlayerManager.currentSongTitle = songTitle
            audioPlayerManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
            lastTargetVolume = targetVolume
            currentVolumeLevel = newVolumeLevel
        } else {
            if lastTargetVolume != targetVolume {
                audioPlayerManager.fadeToVolume(targetVolume: targetVolume, duration: 1.0)
                lastTargetVolume = targetVolume
                currentVolumeLevel = newVolumeLevel
            }
        }
    }
}

