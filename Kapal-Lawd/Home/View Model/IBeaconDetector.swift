//
//  ViewController.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 18/09/24.
//

import CoreLocation
import Combine

class IBeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var beaconRepo = SupabaseBeaconsRepository()
    private var currentBeaconId: String?
    private let beaconIdentifier = "AUDIUM"
    var dataBeacons: [Beacons] = []
    @Published var isFindBeacon = false
    @Published var isBeaconFar = true
    @Published var isBeaconChange = false
    @Published var backgroundSound: String = ""
    @Published var detectedBeacons: [CLBeacon] = []
    @Published var closestBeacon: CLBeacon?
    @Published var isSessionActive: Bool = false
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true

        Task {
            await self.fetchBeaconsAndStartMonitoring()
        }
    }
    
    private func fetchBeaconsAndStartMonitoring() async {
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
                let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: beaconIdentifier)
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
                Task {
                    await self.fetchBeaconsAndStartMonitoring()
                }
                startMonitoring()
            }
        default:
            if isSessionActive {
                stopMonitoring()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        DispatchQueue.main.async {
            for beacon in beacons as [CLBeacon]{
                for data in self.dataBeacons as [Beacons]{
                    if beacon.rssi != 0 || Double(beacon.rssi) >= data.minRssi && Double(beacon.rssi) <= data.maxRssi {
                        
                        let beaconExists = self.detectedBeacons.contains { existingBeacon in
                            return existingBeacon.uuid == beacon.uuid
                        }
                        
                        if !beaconExists {
                            self.detectedBeacons.append(beacon)
                        }
                    } else {
                        self.detectedBeacons = []
                        self.makeDisactive()
                    }
                }
            }
            
            if let nearestBeacon = self.detectedBeacons.max(by: { $0.rssi < $1.rssi }) {
                if self.currentBeaconId != nearestBeacon.uuid.uuidString {
                    self.closestBeacon = nearestBeacon
                    self.currentBeaconId = nearestBeacon.uuid.uuidString
                    self.isBeaconChange = true
                } else {
                    self.isBeaconChange = false
//                    self.startMonitoring()
                }
                
                self.makeActive()
            }
        }
        
        print("current beacon: \(currentBeaconId)")
    }
    
    private func makeActive() {
        self.isBeaconFar = false
        self.isFindBeacon = true
    }
    
    private  func makeDisactive() {
        self.isBeaconFar = true
        self.isFindBeacon = false
    }
}

