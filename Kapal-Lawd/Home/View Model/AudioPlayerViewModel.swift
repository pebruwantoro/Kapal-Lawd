//
//  AudioPlayerViewModel.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 19/09/24.
//

import AVFoundation
import SwiftUI
import Combine

class AudioPlayerViewModel: ObservableObject {
    private var collectionRepo = JSONCollectionsRepository()
    private var playlistRepo = JSONPlaylistRepository()
    private var beaconRepo = SupabaseBeaconsRepository()
    
    @Published var currentBeacon: Beacons?
    @Published var backgroundSound: String?
    @Published var isFind = false
    
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
    
    func fetchBeaconById(id: String) async {
        do {
            let beacon = try await beaconRepo.fetchListBeaconsByUUID(req: BeaconsRequest(uuid: id))
            DispatchQueue.main.async {
                print("fetch beacon: \(beacon)")
                self.currentBeacon = beacon[0]
                self.backgroundSound = beacon[0].backgroundSound
            }
        } catch {
            print("Error fetching beacons: \(error.localizedDescription)")
            // Handle error appropriately (e.g., show an alert or retry)
        }
    }
}



//            // Reset lostBeaconCount since we are within range
//            self.isFindBeacon = true
//            self.isBeaconFar = false
//            self.lostBeaconCount = 0
//            adjustAudioForRSSI(rssi: rssi, minRssi: minRssi, maxRssi: maxRssi)
//        
//           
//                self.isFindBeacon = false
//                self.isBeaconFar = true
//                lastTargetVolume = nil
//                currentVolumeLevel = .none
//                
//    self.lostBeaconCount += 1
//        self.isFindBeacon = false
//        self.isBeaconFar = true
//        audioPlayerManager.stopPlayback()
//        lastTargetVolume = nil
//        currentVolumeLevel = .none
