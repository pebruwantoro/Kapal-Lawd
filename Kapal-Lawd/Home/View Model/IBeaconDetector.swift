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
    @Published var estimatedDistance: Double = -1.0 // Distance in meters

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
    private var emaRSSI: [String: Double] = [:]
    private let emaAlpha: Double = 0.2 // Smoothing factor

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
        guard let locationManager = self.locationManager else { return }
        guard !beaconUUIDs.isEmpty else { return }

        for uuid in beaconUUIDs.compactMap({ $0 }) {
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: beaconIdentifier)
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }

        // Ensure the app continues location updates in the background
        locationManager.startUpdatingLocation()
    }

    // Helper function to create a unique identifier for a beacon
    func beaconIdentifier(for beacon: CLBeacon) -> String {
        return "\(beacon.uuid.uuidString):\(beacon.major):\(beacon.minor)"
    }

    // Public method to get the audio file name
    func getAudioFileName(for identifier: String) -> String? {
        return audioMap[identifier]
    }

    // CLLocationManagerDelegate methods
    func locationManager(
        _ manager: CLLocationManager,
        didRange beacons: [CLBeacon],
        satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
        if beacons.isEmpty {
            closestBeacon = nil
            estimatedDistance = -1.0
            return
        }

        detectedBeacons = beacons

        // Find the beacon with the strongest signal (highest RSSI)
        if let nearestBeacon = beacons.max(by: { $0.rssi < $1.rssi }) {
            let identifier = beaconIdentifier(for: nearestBeacon)
            let smoothedRSSI = smoothRSSI(rssi: nearestBeacon.rssi, for: identifier)
            let distance = estimateDistance(rssi: smoothedRSSI)
            self.closestBeacon = nearestBeacon
            self.estimatedDistance = distance
        } else {
            self.closestBeacon = nil
            self.estimatedDistance = -1.0
        }
    }

    // Smooth the RSSI values using EMA
    private func smoothRSSI(rssi: Int, for beaconIdentifier: String) -> Double {
        if rssi == 0 {
            return -100.0 // Invalid RSSI, return a low value
        }

        // Exponential Moving Average (EMA) for RSSI
        if emaRSSI[beaconIdentifier] == nil {
            emaRSSI[beaconIdentifier] = Double(rssi)
        } else {
            emaRSSI[beaconIdentifier] = emaAlpha * Double(rssi) + (1 - emaAlpha) * emaRSSI[beaconIdentifier]!
        }
        return emaRSSI[beaconIdentifier]!
    }

    // Estimate distance from RSSI
    private func estimateDistance(rssi: Double) -> Double {
        let txPower = -59.0 // Replace with your calibrated Measured Power
        let n = 2.0 // Replace with your calibrated path-loss exponent

        if rssi == 0 {
            return -1.0 // Cannot determine distance
        }

        let ratio = (txPower - rssi) / (10 * n)
        let distance = pow(10, ratio)
        return distance
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
