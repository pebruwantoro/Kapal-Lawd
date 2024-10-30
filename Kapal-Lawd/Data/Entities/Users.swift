//
//  Users.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

struct Users: Codable {
    let uuid: String
    let username: String
    let password: String
    let email: String
    let name: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case username
        case password
        case email
        case name
        case role
    }
}


