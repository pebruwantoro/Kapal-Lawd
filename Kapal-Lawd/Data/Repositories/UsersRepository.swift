//
//  UsersRepository.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 27/09/24.
//

import Foundation

internal protocol UsersRepository {
    func fetchListUsers() -> ([Users], ErrorHandler?)
    func fetchListUsersByUUID(req: UsersRequest) -> ([Users], ErrorHandler?)
}

internal final class JSONUsersRepository: UsersRepository {
    
    private let jsonManager = JsonManager.shared
    
    func fetchListUsers() -> ([Users], ErrorHandler?) {
        let result = jsonManager.loadJSONData(from: "users", as: [Users].self)
        
        switch result {
        case .success(let users):
            return (users, nil)
        case .failure(let error):
            return ([], error)
        }
    }
    
    func fetchListUsersByUUID(req: UsersRequest) -> ([Users], ErrorHandler?) {
        let(users, errorHandler) = fetchListUsers()
        
        if let error = errorHandler {
            return ([], error)
        }
        
        let result = users.filter {
            $0.uuid == req.uuid
        }
        
        return (result, nil)
    }
}
