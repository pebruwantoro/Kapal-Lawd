//
//  ViewController.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 18/09/24.
//

import CoreLocation

class IBeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var proximity: CLProximity = .unknown
    private var locationManager: CLLocationManager?
    private let beaconUUID = UUID(uuidString: "2D7A9F0C-E0E8-4CC9-A71B-A21DB2D034A1")
    private let beaconIdentifier = "Beacon1"
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        // Minta izin untuk "Always Authorization"
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager?.requestAlwaysAuthorization()
        }
        
        // Aktifkan untuk pemindaian lokasi secara berkelanjutan
        locationManager?.allowsBackgroundLocationUpdates = true
        
        startMonitoring()
    }
    
    func startMonitoring() {
        guard let beaconUUID = beaconUUID else { return }
        
        // Buat region untuk beacon dengan UUID, major, dan minor
        let beaconRegion = CLBeaconRegion(uuid: beaconUUID, major: 5, minor: 88, identifier: beaconIdentifier)
        
        // Mulai monitor dan ranging untuk region
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
        
        // Pastikan aplikasi terus melakukan pemindaian lokasi di background
        locationManager?.startUpdatingLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let nearestBeacon = beacons.first {
            proximity = nearestBeacon.proximity
            print("Detect : \(nearestBeacon)")
        } else {
            proximity = .unknown
            print("No Beacons")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Ketika masuk ke region beacon, mulai ranging
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager?.startRangingBeacons(in: beaconRegion)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Hentikan ranging saat keluar dari region beacon
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager?.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Tetap kosong, cukup untuk menjaga aplikasi tetap berjalan di background
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Pastikan izin "Always" telah diberikan
        if status == .authorizedAlways {
            startMonitoring()
        }
    }
}
