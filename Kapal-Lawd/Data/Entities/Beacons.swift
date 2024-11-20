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
    let xPosition: Double
    let yPosition: Double
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case backgroundSound = "background_sound"
        case minRssi = "min_rssi"
        case maxRssi = "max_rssi"
        case xPosition = "x_position"
        case yPosition = "y_position"
    }
}

struct Point {
    let xPosition: Double
    let yPosition: Double
}

struct BeaconData {
    let uuid: String
    let rssi: Double
    let distance: Double
    let position: Point
}

struct DetectedBeacon {
    let uuid: String
    let estimatedDitance: Double
    let euclideanDistance: Double
    let averageDistance: Double
    let userPosition: Point
}

extension BeaconData: Hashable {
    static func == (lhs: BeaconData, rhs: BeaconData) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

extension DetectedBeacon: Hashable {
    static func == (lhs: DetectedBeacon, rhs: DetectedBeacon) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
