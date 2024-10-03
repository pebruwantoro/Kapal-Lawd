//
//  ViewController.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 18/09/24.
//

import CoreLocation
import Combine

class IBeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Published properties
    @Published var detectedBeacons: [CLBeacon] = []
    @Published var closestBeacon: CLBeacon?
    @Published var estimatedDistance: Double = -1.0

    // Private properties
    private var locationManager: CLLocationManager?
    private let beaconUUIDs = [
        UUID(uuidString: "EF63C140-2AF4-4E1E-AAB3-340055B3BB4A"),
        UUID(uuidString: "EF63C140-2AF4-4E1E-AAB3-340055B3BB4D")
    ]
    private let beaconIdentifier = "MyBeacons"
    private var audioMap: [String: String] = [
        "EF63C140-2AF4-4E1E-AAB3-340055B3BB4A:0:0": "dreams",
        "EF63C140-2AF4-4E1E-AAB3-340055B3BB4D:0:0": "Naruto Soundtrack - The Raising Fighting Spirit"
    ]
    private var rssiReadings: [String: [Int]] = [:]
    private var consecutiveCloserReadings = 0
    private let requiredConsecutiveReadings = 3
    private let switchingThreshold = 0.5 // meters

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        // Request "Always Authorization"
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager?.requestAlwaysAuthorization()
        }

        // Enable continuous location scanning
        locationManager?.allowsBackgroundLocationUpdates = true

        startMonitoring()
    }

    func startMonitoring() {
        guard !beaconUUIDs.isEmpty else { return }

        for uuid in beaconUUIDs.compactMap({ $0 }) {
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: beaconIdentifier)
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }

        // Ensure the app continues location updates in the background
        locationManager?.startUpdatingLocation()
    }

    // Helper function to create a unique identifier for a beacon
    func beaconIdentifier(for beacon: CLBeacon) -> String {
        return "\(beacon.uuid.uuidString):\(beacon.major):\(beacon.minor)"
    }

    // Public method to get the audio file name
    func getAudioFileName(for identifier: String) -> String? {
        return audioMap[identifier]
    }

    // Distance estimation function
    private func estimateDistance(rssi: Int, for beaconIdentifier: String) -> Double {
        let txPower = -59 // Calibrated value
        let n: Double = 2.0 // Adjust based on environment
        if rssi == 0 {
            return -1.0 // Cannot determine distance
        }

        // Collect RSSI readings for averaging
        if rssiReadings[beaconIdentifier] == nil {
            rssiReadings[beaconIdentifier] = []
        }
        rssiReadings[beaconIdentifier]?.append(rssi)
        if rssiReadings[beaconIdentifier]!.count > 10 {
            rssiReadings[beaconIdentifier]?.removeFirst()
        }
        let averageRSSI = rssiReadings[beaconIdentifier]!.reduce(0, +) / rssiReadings[beaconIdentifier]!.count

        let ratio = Double(txPower - averageRSSI) / (10 * n)
        let distance = pow(10, ratio)
        return distance
    }

    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if beacons.isEmpty {
            closestBeacon = nil
            estimatedDistance = -1.0
            return
        }

        detectedBeacons = beacons

        var nearestBeacon: CLBeacon?
        var smallestDistance: Double = Double.greatestFiniteMagnitude

        for beacon in beacons {
            let identifier = beaconIdentifier(for: beacon)
            let distance = estimateDistance(rssi: beacon.rssi, for: identifier)
            if distance >= 0 {
                if distance < smallestDistance {
                    smallestDistance = distance
                    nearestBeacon = beacon
                }
            }
        }

        if let nearest = nearestBeacon {
            let identifier = beaconIdentifier(for: nearest)
            let distanceDifference = estimatedDistance - smallestDistance

            if let currentClosest = self.closestBeacon {
                let currentIdentifier = beaconIdentifier(for: currentClosest)
                if identifier != currentIdentifier {
                    if distanceDifference > switchingThreshold {
                        consecutiveCloserReadings += 1
                        if consecutiveCloserReadings >= requiredConsecutiveReadings {
                            // Switch to the new beacon
                            self.closestBeacon = nearest
                            estimatedDistance = smallestDistance
                            consecutiveCloserReadings = 0
                        }
                    } else {
                        consecutiveCloserReadings = 0
                    }
                } else {
                    // Same beacon remains closest
                    self.closestBeacon = nearest
                    estimatedDistance = smallestDistance
                    consecutiveCloserReadings = 0
                }
            } else {
                // No current closest beacon
                self.closestBeacon = nearest
                estimatedDistance = smallestDistance
                consecutiveCloserReadings = 0
            }
        } else {
            self.closestBeacon = nil
            estimatedDistance = -1.0
            consecutiveCloserReadings = 0
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager?.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Keep empty; sufficient to keep the app running in the background
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            startMonitoring()
        }
    }
}
