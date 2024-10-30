//
//  Venues.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

struct Venues: Codable {
    let uuid: String
    let name: String
    let location: String
    let type: String
    let soundName: String
    let createdAt: Date
    let createdBy: String
    let updatedAt: Date?
    let updatedBy: String?
    let deletedAt: Date?
    let deletedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case name
        case location
        case type
        case soundName = "sound_name"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case updatedAt = "updated_at"
        case updatedBy = "updated_by"
        case deletedAt = "deleted_at"
        case deletedBy = "deleted_by"
    }
}

