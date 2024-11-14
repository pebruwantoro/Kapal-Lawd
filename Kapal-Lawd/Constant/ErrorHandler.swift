//
//  ErrorHandler.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

enum ErrorHandler: LocalizedError {
    case fileNotFound
    case decodingFailed(Error)
    case encodingFailed(Error)
    case dataCorrupted
    case networkError(Error)
    case unknownError(Error)
    case errorMultilateration
    case errorSolveLinearSystem
    case errorRSSIZeroValue

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The requested file was not found."
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .dataCorrupted:
            return "The data is corrupted."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .errorMultilateration:
            return "Need at least 3 beacons for multilateration"
        case .errorSolveLinearSystem:
            return "Unable to solve linear system."
        case .errorRSSIZeroValue:
            return "RSSI is zero, cannot calculate distance."
        }
    }
}
