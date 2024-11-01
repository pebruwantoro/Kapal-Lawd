//
//  BeaconsRepository.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation
import Supabase

internal protocol BeaconsRepository {
    func fetchListBeacons() async throws -> [Beacons]
    func fetchListBeaconsByUUID(req: BeaconsRequest) async throws -> [Beacons]
}

internal final class JSONBeaconsRepository: BeaconsRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListBeacons() async throws -> [Beacons] {
        let result = jsonManager.loadJSONData(from: "Beacons", as: [Beacons].self)
        switch result {
        case .success(let beacons):
            return beacons
        case .failure(let error):
            throw mapErrorToErrorHandler(error)
        }
    }
    
    func fetchListBeaconsByUUID(req: BeaconsRequest) async throws -> [Beacons] {
        let beacons = try await fetchListBeacons()
        let filteredBeacons = beacons.filter { $0.uuid == req.uuid }
        return filteredBeacons
    }
    
    private func mapErrorToErrorHandler(_ error: Error) -> ErrorHandler {
        if let errorHandler = error as? ErrorHandler {
            return errorHandler
        } else {
            return .unknownError(error)
        }
    }
}

internal final class SupabaseBeaconsRepository: BeaconsRepository {
    
    private let supabaseClient = SupabaseManager.shared
    
    func fetchListBeacons() async throws -> [Beacons] {
        do {
            let beacons: [Beacons] = try await supabaseClient
                .from("iBeacon")
                .select("id, created_at, UUID, background_sound, min_rssi, max_rssi")
                .execute()
                .value
            print(beacons)
            return beacons
        } catch {
            throw mapErrorToErrorHandler(error)
        }
    }
    
    func fetchListBeaconsByUUID(req: BeaconsRequest) async throws -> [Beacons] {
        do {
            let beacons: [Beacons] = try await supabaseClient
                .from("iBeacon")
                .select("id, created_at, UUID, background_sound, min_rssi, max_rssi")
                .eq("UUID", value: req.uuid)
                .execute()
                .value
            return beacons
        } catch {
            throw mapErrorToErrorHandler(error)
        }
    }
    
    // Helper method to map errors to your ErrorHandler enum
    private func mapErrorToErrorHandler(_ error: Error) -> ErrorHandler {
        if let decodingError = error as? DecodingError {
            return .decodingFailed(decodingError)
        } else if let urlError = error as? URLError {
            return .networkError(urlError)
        } else {
            return .unknownError(error)
        }
    }
}
