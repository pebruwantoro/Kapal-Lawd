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
        supabaseURL: URL(string: Bundle.main.infoDictionary?["SUPABASE_BASE_URL"] as? String ?? "")!,
        supabaseKey: Bundle.main.infoDictionary?["SUPABASE_API_KEY"] as? String ?? ""
        
    )
}
