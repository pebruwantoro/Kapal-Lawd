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
    let minRssi: Float
    let maxRssi: Float
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case backgroundSound = "background_sound"
        case minRssi
        case maxRssi
    }
}
