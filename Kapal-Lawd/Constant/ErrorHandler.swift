//
//  ErrorHandler.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

enum ErrorHandler: Error {
    case fileNotFound
    case decodedFailed(Error)
    case encodedFailed(Error)
    case dataCorrupted
}
