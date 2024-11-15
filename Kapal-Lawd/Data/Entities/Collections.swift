//
//  Collections.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

struct Collections: Codable {
    let uuid: String
    let roomId: String
    let name: String
    let beaconId: String
    let longContents: String
    let shortContents: String
    let authoredBy: String
    let authoredAt: String

    enum CodingKeys: String, CodingKey {
        case uuid
        case roomId = "room_id"
        case name
        case beaconId = "beacon_id"
        case longContents = "long_contents"
        case shortContents = "short_contents"
        case authoredBy = "authored_by"
        case authoredAt = "authored_at"
    }
}
