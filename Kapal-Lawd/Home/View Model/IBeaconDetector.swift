//
//  ViewController.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 18/09/24.
//

import Foundation
import CoreLocation
import Combine

class IBeaconDetector: NSObject, CLLocationManagerDelegate, ObservableObject {
    let locationManager = CLLocationManager()
    let uuidString = "39B39463-B2EF-444E-A1C5-0921641A338F"
    var constraint: CLBeaconIdentityConstraint!
    
    @Published var proximity: CLProximity = .unknown
    
    override init() {
        super.init()
        
        if let uuid = UUID(uuidString: uuidString) {
            constraint = CLBeaconIdentityConstraint(uuid: uuid)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "kCBAdvDataAppleBeaconKey")
            
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
            print("correct beacon ID")
        } else {
            print("Invalid UUID string")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            print("Entered beacon region!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLBeaconRegion {
            print("Exited beacon region!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print(beacons.count)
        if let beacon = beacons.first {
            self.proximity = beacon.proximity
            print("check proximity")
        }
    }
}


