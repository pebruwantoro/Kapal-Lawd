//
//  PlaylistRepository.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 11/10/24.
//

import Foundation

internal protocol PlaylistRepository {
    func fetchListPlaylist() -> ([Playlist], ErrorHandler?)
    func fetchPlaylistByCollectionId(req: PlaylistRequest) -> ([Playlist], ErrorHandler?)
}

internal final class JSONPlaylistRepository: PlaylistRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListPlaylist() -> ([Playlist], ErrorHandler?) {
        let result = jsonManager.loadJSONData(from: "Playlists", as: [Playlist].self)
       
        switch result {
        case .success(let playlist):
            return (playlist, nil)
        case .failure(let error):
            return ([], error)
        }
    }
    
    func fetchPlaylistByCollectionId(req: PlaylistRequest) -> ([Playlist], ErrorHandler?) {
        let (playlist, errorHandler) = fetchListPlaylist()
        
        if let error = errorHandler {
            return([], error)
        }
        
        let result = playlist.filter {
            $0.collectionId == req.collectionId
        }
        
        return (result ,nil)
    }
}
