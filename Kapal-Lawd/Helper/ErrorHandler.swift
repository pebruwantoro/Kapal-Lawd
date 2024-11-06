//
//  ErrorHandler.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 06/11/24.
//

import Foundation

extension ErrorHandler {
    static func map(_ error: Error) -> ErrorHandler {
        if let errorHandler = error as? ErrorHandler {
            return errorHandler
        } else if let decodingError = error as? DecodingError {
            return .decodingFailed(decodingError)
        } else if let urlError = error as? URLError {
            return .networkError(urlError)
        } else {
            return .unknownError(error)
        }
    }
}
