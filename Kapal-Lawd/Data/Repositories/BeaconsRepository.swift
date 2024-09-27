//
//  BeaconsRepository.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

internal protocol BeaconsRepository {
    func fetchListBeacons() -> ([Beacons], ErrorHandler?)
    func fetchListBeaconsByUUID(req: BeaconsRequest) -> ([Beacons], ErrorHandler?)
}

internal final class JSONBeaconsRepository: BeaconsRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListBeacons() -> ([Beacons], ErrorHandler?) {
        let result = jsonManager.loadJSONData(from: "Beacons", as: [Beacons].self)
        
        switch result {
        case .success(let beacons):
            return (beacons, nil)
        case .failure(let error):
            return ([], error)
        }
    }
    
    func fetchListBeaconsByUUID(req: BeaconsRequest) -> ([Beacons], ErrorHandler?) {
        let (beacons, errorHandler) = fetchListBeacons()
        
        if let error = errorHandler {
            return ([], error)
        }
        
        let result = beacons.filter {
            $0.uuid == req.uuid
        }
        
        return (result, nil)
    }
    
}
