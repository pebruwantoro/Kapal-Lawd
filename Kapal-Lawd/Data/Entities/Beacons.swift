//
//  Beacons.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

struct Beacons: Codable {
    let uuid: String
    let backgroundSound: String
    let minRssi: Double
    let maxRssi: Double
    
    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case backgroundSound = "background_sound"
        case minRssi = "min_rssi"
        case maxRssi = "max_rssi"
    }
}
