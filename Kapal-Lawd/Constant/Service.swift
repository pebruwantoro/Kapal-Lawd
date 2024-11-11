//
//  Service.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 05/11/24.
//
import Foundation

enum SupabaseSerivce {
    static var baseURL: String {
        return Bundle.main.infoDictionary?["SUPABASE_BASE_URL"] as? String ?? ""
    }
    static var apiKey: String {
        return Bundle.main.infoDictionary?["SUPABASE_API_KEY"] as? String ?? ""
    }
}
