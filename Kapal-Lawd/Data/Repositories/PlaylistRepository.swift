//
//  PlaylistRepository.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 11/10/24.
//

import Foundation

internal protocol PlaylistRepository {
    func fetchListPlaylist() async throws -> [Playlist]
    func fetchPlaylistByCollectionId(req: PlaylistRequest) async throws -> [Playlist]
}

internal final class JSONPlaylistRepository: PlaylistRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListPlaylist() async throws -> [Playlist] {
        let result = jsonManager.loadJSONData(from: "Playlists", as: [Playlist].self)
        switch result {
        case .success(let playlist):
            return playlist
        case .failure(let error):
            throw mapErrorToErrorHandler(error)
        }
    }
    
    func fetchPlaylistByCollectionId(req: PlaylistRequest) async throws -> [Playlist] {
        let playlist = try await fetchListPlaylist()
        let filteredPlaylist = playlist.filter { $0.collectionId == req.collectionId }
        return filteredPlaylist
    }
}

internal final class SupabasePlaylistRepository: PlaylistRepository {
    
    private let supabaseClient = SupabaseManager.shared
    
    func fetchListPlaylist() async throws -> [Playlist] {
        do {
            let playlist: [Playlist] = try await supabaseClient
                .from("playlists")
                .select("uuid, collection_id, name, duration, url")
                .order("name", ascending: true)
                .execute()
                .value
            return playlist
        } catch {
            throw mapErrorToErrorHandler(error)
        }
    }
    
    func fetchPlaylistByCollectionId(req: PlaylistRequest) async throws -> [Playlist] {
        do {
            let playlist: [Playlist] = try await supabaseClient
                .from("playlists")
                .select("uuid, collection_id, name, duration, url")
                .eq("collection_id", value: req.collectionId)
                .order("name", ascending: true)
                .execute()
                .value
            return playlist
        } catch {
            throw mapErrorToErrorHandler(error)
        }
    }
}
