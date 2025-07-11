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
    private var beaconRepo = SupabaseBeaconsRepository()
    private var beaconData: Beacons?
    private var lastTargetVolume: Float? = nil
    private var currentVolumeLevel: VolumeLevel = .none
    private var isStop = false
    private var tempClosestBeacons: [DetectedBeacon] = []
    private var timerScanner: Timer?
    private var distances: [String:[Double]] = [:]
    @ObservedObject private var audioPlayerManager = AVManager.shared
    @Published var isFindBeacon = false
    @Published var detectedBeacons : [DetectedBeacon] = []
    @Published var closestBeacon: CLBeacon?
    @Published var isSessionActive: Bool = false
    @Published var dataBeacons: [Beacons] = []
    
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
        self.isStop = false
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
        self.isStop = true
        self.isSessionActive = false
        self.timerScanner?.invalidate()
        self.timerScanner = nil

    }
    
    // Helper function to create a unique identifier for a beacon
    func beaconIdentifier(for beacon: CLBeacon) -> String {
        // Modify as needed to include major and minor if necessary
        return "\(beacon.uuid.uuidString.lowercased())"
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if !self.isStop {
            if let beaconRegion = region as? CLBeaconRegion {
                locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if !self.isStop {
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
        if !self.isStop {
            startCollectingDistances(beacons: beacons)
        }
    }
    
    private func startCollectingDistances(beacons: [CLBeacon]) {
        for beacon in beacons {
            let distance = self.distanceFromRSSI(rssi: Double(beacon.rssi))
            if distance != -1 && distance <= Beacon.maxInRange.rawValue {
                distances[beacon.uuid.uuidString.lowercased(), default: []].append(distance)
                
                if distances[beacon.uuid.uuidString.lowercased()]!.count > 5 {
                    distances[beacon.uuid.uuidString.lowercased()]!.removeFirst()
                }
            } else {
                self.distances.removeValue(forKey: beacon.uuid.uuidString.lowercased())
                distances[beacon.uuid.uuidString.lowercased(), default: []].append(distance)
                if distances[beacon.uuid.uuidString.lowercased()]!.count > 5 {
                    distances[beacon.uuid.uuidString.lowercased()]!.removeFirst()
                }
            }
        }
        
        timerScanner = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.timerScanner?.invalidate()
            self.timerScanner = nil
            self.detectedBeacons(beacons: distances)
        }
    }
    
    private func detectedBeacons(beacons: [String:[Double]]) {
        if !self.dataBeacons.isEmpty {
            for (beaconId, distances) in beacons {
                let tempBeacon = self.dataBeacons.first{ $0.uuid == beaconId.lowercased() }
                
                let distance = distances.reduce(0, +) / Double(distances.count)
                
                if distance != -1 && distance <= Beacon.maxInRange.rawValue {
                    let temp = DetectedBeacon(
                        uuid: beaconId,
                        estimatedDitance: distance,
                        euclideanDistance: distance,
                        averageDistance: distance,
                        userPosition: Point(
                            xPosition: tempBeacon!.xPosition,
                            yPosition: tempBeacon!.yPosition)
                    )
                    self.tempClosestBeacons.append(temp)
                } else {
                    self.distances.removeValue(forKey: beaconId)
                    self.tempClosestBeacons.removeAll(where: { $0.uuid == beaconId })
                    self.detectedBeacons.removeAll(where: { $0.uuid == beaconId })
                }
            }
            
            self.detectedBeacons = Array(Set(self.tempClosestBeacons.sorted(by: { $0.estimatedDitance < $1.estimatedDitance })))
            
            self.makeActive()
        } else {
            self.makeDisactive()
        }
    }
    
    private func makeActive() {
        self.isFindBeacon = true
    }
    
    private func makeDisactive() {
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
    
    func distanceFromRSSI(rssi: Double) -> Double {
        guard rssi != 0 else {
            return -1.0
        }
        
        let ratio = (-59 - rssi) / (10 * 2)
        let distance = pow(10, ratio)
        
        return distance
    }
}

