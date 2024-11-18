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
}

internal final class SupabaseBeaconsRepository: BeaconsRepository {
    
    private let supabaseClient = SupabaseManager.shared
    
    func fetchListBeacons() async throws -> [Beacons] {
        do {
            let beacons: [Beacons] = try await supabaseClient
                .from("beacons")
                .select("uuid, background_sound, min_rssi, max_rssi")
                .execute()
                .value
            return beacons
        } catch {
            throw mapErrorToErrorHandler(error)
        }
    }
    
    func fetchListBeaconsByUUID(req: BeaconsRequest) async throws -> [Beacons] {
        do {
            let beacons: [Beacons] = try await supabaseClient
                .from("beacons")
                .select("uuid, background_sound, min_rssi, max_rssi")
                .eq("UUID", value: req.uuid)
                .execute()
                .value
            return beacons
        } catch {
            throw mapErrorToErrorHandler(error)
        }
    }
}
