//
//  Beacons.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

struct Beacons: Codable {
    let uuid: String
    
    
    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
    }
}
