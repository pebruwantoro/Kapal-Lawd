//
//  Playlist.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 11/10/24.
//

import Foundation

struct Playlist: Codable {
    let uuid: String
    let collectionId: String
    let name: String
    let duration: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case uuid
        case collectionId = "collection_id"
        case name
        case duration
        case url
    }
}
