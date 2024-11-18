//
//  AudioPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 19/09/24.
//

import AVFoundation
import SwiftUI

class AudioPlayerViewModel: ObservableObject {
    private var collectionRepo = JSONCollectionsRepository()
    private var playlistRepo = JSONPlaylistRepository()
//    private var beaconRepo = SupabaseBeaconsRepository()
    private var beaconRepo = JSONBeaconsRepository()
    @ObservedObject private var beaconScanner = IBeaconDetector()
    @Published var currentBeacon: Beacons?
    @Published var backgroundSound: String?
    
    func fetchCollectionByBeaconId(id: String) -> [Collections] {
        let result = collectionRepo.fetchListCollectionsByBeaconId(req: CollectionsRequest(beaconId: id))
        let errorHandler = result.1
        
        if let errorHandler = errorHandler {
            print("error: \(errorHandler)")
        }
        
        return result.0
    }
    
    func fetchPlaylistByCollectionId(id: String) -> [Playlist] {
        let result = playlistRepo.fetchPlaylistByCollectionId(req: PlaylistRequest(collectionId: id))
        let errorHandler = result.1
        
        if let errorHandler = errorHandler {
            print("error: \(errorHandler)")
        }
        
        return result.0
    }
    
    func fetchBeaconById(id: String) -> Beacons? {
        return beaconScanner.dataBeacons.first { $0.uuid == id }
    }
}
