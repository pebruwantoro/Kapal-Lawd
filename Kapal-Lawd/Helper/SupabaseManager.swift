//
//  SupabaseManager.swift
//  Kapal-Lawd
//
//  Created by Romi Fadhurohman Nabil on 30/10/24.
//

import Foundation
import Supabase

struct SupabaseManager {
    static let shared = SupabaseClient(
        supabaseURL: URL(string: SupabaseSerivce.baseURL)!,
        supabaseKey: SupabaseSerivce.apiKey
    )
}
