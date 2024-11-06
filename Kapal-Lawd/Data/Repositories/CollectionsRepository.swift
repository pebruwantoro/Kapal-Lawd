//
//  CollectionsRepository.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation
import Supabase

internal protocol CollectionsRepository {
    func fetchListCollections() async throws -> [Collections]
    func fetchListCollectionsByBeaconId(req: CollectionsRequest) async throws -> [Collections]
}

internal final class JSONCollectionsRepository: CollectionsRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListCollections() async throws -> [Collections] {
        let result = jsonManager.loadJSONData(from: "Collections", as: [Collections].self)
        switch result {
        case .success(let collections):
            return collections
        case .failure(let error):
            throw ErrorHandler.map(error)
        }
    }
    
    func fetchListCollectionsByBeaconId(req: CollectionsRequest) async throws -> [Collections] {
        let collections = try await fetchListCollections()
        let filteredCollections = collections.filter { $0.beaconId == req.beaconId }
        return filteredCollections
    }
}

internal final class SupabaseCollectionsRepository: CollectionsRepository {
    
    private let supabaseClient = SupabaseManager.shared
    
    func fetchListCollections() async throws -> [Collections] {
        do {
            let collections: [Collections] = try await supabaseClient
                .from("Collections")
                .select("id, created_at, uuid, rooms_id, name, beacon_id, long_contents, short_contents, authored_by, authored_at")
                .execute()
                .value
            return collections
        } catch {
            throw ErrorHandler.map(error)
        }
    }
    
    func fetchListCollectionsByBeaconId(req: CollectionsRequest) async throws -> [Collections] {
        do {
            let collections: [Collections] = try await supabaseClient
                .from("Collections")
                .select("id, created_at, uuid, rooms_id, name, beacon_id, long_contents, short_contents, authored_by, authored_at")
                .eq("beacon_id", value: req.beaconId)
                .execute()
                .value
            return collections
        } catch {
            throw ErrorHandler.map(error)
        }
    }
}
