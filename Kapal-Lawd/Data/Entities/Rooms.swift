//
//  Rooms.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

struct Rooms: Codable {
    let uuid: String
    let venuesId: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case venuesId = "venues_id"
        case name
    }
}
