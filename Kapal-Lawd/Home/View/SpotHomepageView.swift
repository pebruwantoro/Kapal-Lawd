//
//  SpotHomepageView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 15/10/24.
//

import SwiftUI

struct SpotHomepageView: View {
    @State private var isExploring = false
    @State private var beaconId: String?
    @State private var trackBar = 0.0
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()
    
    var body: some View {
        NavigationStack {
            if isExploring {
                FindAuditagView(isExploring: self.$isExploring, trackBar: self.$trackBar)
                    .environmentObject(audioPlayerViewModel)
            } else {
                Spacer()
                VStack (spacing: 16) {
                    VStack {
                        Image("audiumlogo")
                    }
                    .frame(width: 313, alignment: .leading)
                    
                    VStack {
                        Text("Audium")
                            .bold()
                            .font(.title)
                            .foregroundColor(Color("AppText"))
                            .frame(width: 317, alignment: .leading)
                        Text("Begin your audio-guided museum experience")
                            .font(.subheadline)
                            .foregroundColor(Color("AppText"))
                            .frame(width: 317, alignment: .leading)
                    }
                    
                    VStack {
                        Button(action: {
                            isExploring = true
                            ButtonHaptic()
                        }, label: {
                            Text("Start Exploration")
                                .foregroundColor(.white)
                                .font(.body)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(.black)
                                .cornerRadius(86)
                        })
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: 230)
                .background(.white)
                .cornerRadius(36)
                .shadow(radius: 5)
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    SpotHomepageView()
}
