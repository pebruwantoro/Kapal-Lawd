//
//  VenuesRepository.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

internal protocol VenuesRepository {
    func fetchListVenues() -> ([Venues], ErrorHandler?)
    func fetchVenuesByUUID(req: VenuesRequest) -> (Venues?, ErrorHandler?)
}

internal final class JSONVenuesRepository: VenuesRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListVenues() -> ([Venues], ErrorHandler?) {
        let result = jsonManager.loadJSONData(from: "Venues", as: [Venues].self)
        
        switch result {
        case .success(let venues):
            return(venues, nil)
        case .failure(let error):
            return([], error)
        }
    }
    
    func fetchVenuesByUUID(req: VenuesRequest) -> (Venues?, ErrorHandler?) {
        let (venues, errorHandler) = fetchListVenues()
        
        if let error = errorHandler {
            return (nil, error)
        }
        
        let result = venues.first {
            $0.uuid == req.uuid
        }
        
        return (result, nil)
    }
}
