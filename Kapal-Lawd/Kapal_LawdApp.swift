//
//  Kapal_LawdApp.swift
//  Kapal Lawd
//
//  Created by Doni Pebruwantoro on 18/09/24.
//

import SwiftUI

@main
struct Kapal_LawdApp: App {
    private let refreshTaskID = "com.Kapal-Lawd.refresh"
    var body: some Scene {
        WindowGroup {
           SpotHomepageView()
                .onAppear{
                    
                }
        }
    }
}
