//
//  SessionPage.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 18/09/24.
//

import SwiftUI

struct SessionPage: View {
    var museumName = ["Select Museum", "Kapal Lawd Museum"]
    @State private var selectedMuseum = "Select Museum"
    @State private var selectedSession = false
    
    init() {
          let appearance = UINavigationBarAppearance()
          appearance.configureWithOpaqueBackground()
          appearance.backgroundColor = .white
          appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
          appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
          
          UINavigationBar.appearance().scrollEdgeAppearance = appearance
      }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Session")) {
                    HStack {
                        Text("Museum")
                        Spacer()
                        Picker("", selection: $selectedMuseum) {
                            ForEach(museumName, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.automatic)
                    }
                    
                    HStack {
                        Toggle(isOn: $selectedSession) {
                            Text("Session")
                        }
                    }
                }
                
                if selectedSession {
                    Section(header: Text("Debug Info")) {
                        HStack {
                            Text("Nearest Beacon")
                        }
                        HStack {
                            Text("Beacon ID")
                        }
                        HStack {
                            Text("Current Audio")
                        }
                        HStack {
                            Text("Duration")
                        }
                    }
                }
            }
            .navigationTitle("Audium.")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Alpha Version 1.0 (Mark I)")
                        .font(.footnote)
                }
            }
        }
    }
}

#Preview {
    SessionPage()
}
