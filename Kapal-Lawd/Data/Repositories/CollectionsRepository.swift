//
//  CollectionsRepository.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

internal protocol CollectionsRepository {
    func fetchListCollections() -> ([Collections], ErrorHandler?)
    func fetchListCollectionsByBeaconId(req: CollectionsRequest) -> ([Collections], ErrorHandler?)
}

internal final class JSONCollectionsRepository: CollectionsRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListCollections() -> ([Collections], ErrorHandler?) {
        let result = jsonManager.loadJSONData(from: "Collections", as: [Collections].self)
        
        switch result {
        case .success(let collections):
            return (collections, nil)
        case .failure(let error):
            return ([], error)
        }
    }
    
    func fetchListCollectionsByBeaconId(req: CollectionsRequest) -> ([Collections], ErrorHandler?) {
        let (collections, errorHandler) = fetchListCollections()
        
        if let error = errorHandler {
            return([], error)
        }
        
        let result = collections.filter {
            $0.beaconId == req.beaconId
        }
        
        return (result ,nil)
    }
}
