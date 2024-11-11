//
//  AudioPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 19/09/24.
//

import AVFoundation
import SwiftUI

class AudioPlayerViewModel: ObservableObject {
    private var collectionRepo = SupabaseCollectionsRepository()
    private var playlistRepo = SupabasePlaylistRepository()
    private var beaconRepo = SupabaseBeaconsRepository()
    @ObservedObject private var beaconScanner = IBeaconDetector()
    @Published var currentBeacon: Beacons?
    @Published var backgroundSound: String?
    
    func fetchCollectionByBeaconId(id: String) async -> [Collections] {
        do {
            let collections = try await collectionRepo.fetchListCollectionsByBeaconId(req: CollectionsRequest(beaconId: id))
            return collections
        } catch {
            print("Error fetching collections: \(error)")
            return []
        }
    }
    
    func fetchPlaylistByCollectionId(id: String) async -> [Playlist] {
        do {
            let playlists = try await playlistRepo.fetchPlaylistByCollectionId(req: PlaylistRequest(collectionId: id))
            return playlists
        } catch {
            print("Error fetching playlists: \(error)")
            return []
        }
    }
    
    func fetchBeaconById(id: String) -> Beacons? {
        return beaconScanner.dataBeacons.first { $0.uuid == id }
    }
}
