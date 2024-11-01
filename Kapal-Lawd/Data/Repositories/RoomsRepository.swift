//
//  RoomsRepository.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

internal protocol RoomsRepository {
    func fetchListRooms() -> ([Rooms], ErrorHandler?)
    func fetchListRoomsByUUID(req: RoomsRequest) -> ([Rooms], ErrorHandler?)
}

internal final class JSONRoomsRepository: RoomsRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListRooms() -> ([Rooms], ErrorHandler?) {
        let result = jsonManager.loadJSONData(from: "Rooms", as: [Rooms].self)
        
        switch result {
        case .success(let rooms):
            return (rooms, nil)
        case .failure(let error):
            return ([], error)
        }
    }
    
    func fetchListRoomsByUUID(req: RoomsRequest) -> ([Rooms], ErrorHandler?) {
        let (rooms, errorHandler) = fetchListRooms()
        
        if let error = errorHandler {
            return ([], error)
        }
        
        let result = rooms.filter {
            $0.uuid == req.uuid
        }
        return (result, nil)
    }
}
