//
//  FindAuditagView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 16/10/24.
//

import SwiftUI

struct FindAuditagView: View {
    @Binding var isExploring: Bool
    @State private var isScanning = false
    @State private var cardOpacity = 0.0
    @State var collections: [Collections] = []
    @State var pulseScan = Animation.easeOut(duration: 2).repeatForever(autoreverses: true)
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    @StateObject private var playlistPlayerViewModel: PlaylistPlayerViewModel = PlaylistPlayerViewModel()
    @StateObject private var backgroundPlayerViewModel: BackgroundPlayerViewModel = BackgroundPlayerViewModel()
    @StateObject private var interactionPlayerViewModel: InteractionPlayerViewModel = InteractionPlayerViewModel()
    @State private var isPlayInteraction = false
    
    var body: some View {
        Group {
            Spacer()
            
            if audioPlayerViewModel.isFindBeacon {
                PlaylistView(isExploring: self.$isExploring, collections: self.$collections)
                    .onReceive(audioPlayerViewModel.$isFindBeacon) { value in
                        if !isPlayInteraction {
                            interactionPlayerViewModel.startInteractionSound(song: DeafultSong.interaction.rawValue)
                            isPlayInteraction = value
                        }
                    }
                    .environmentObject(audioPlayerViewModel)
                    .environmentObject(playlistPlayerViewModel)
                    .environmentObject(backgroundPlayerViewModel)
            } else {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.89, green: 0, blue: 0.52).opacity(0.2))
                            .frame(maxWidth: 70)
                            .scaleEffect(isScanning ? 0.7 : 2.4)
                            .animation(pulseScan.delay(0.6), value: isScanning)
                            .animation(.easeInOut(duration: 1), value: isScanning)
                        
                        Image("scanning")
                            .padding(.top, 45)
                            .padding(.bottom, 45)
                    }
                    .onAppear {
                        self.isScanning = true
                        withAnimation(.easeOut(duration: 0.8)) {
                            cardOpacity = 1.0
                        }
                    }
                    
                    VStack {
                        Text("Scanning AudiTag...")
                            .bold()
                            .font(.title3)
                            .foregroundColor(Color("AppText"))
                            .padding(.bottom, 12)
                        
                        Text("Please come closer to the collection")
                            .font(.callout)
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 313)
                    
                    VStack {
                        Button(action: {
                            self.isExploring = false
                            ButtonHaptic()
                        }, label: {
                            Text("Stop Scanning")
                                .foregroundColor(.gray)
                                .font(.body)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                                .cornerRadius(86)
                        })
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: 380)
                .background(.white)
                .cornerRadius(36)
                .shadow(radius: 5)
                .padding(.horizontal, 16)
                .opacity(cardOpacity)
            }
        }
        .onReceive(audioPlayerViewModel.$isFindBeacon) { value in
            if !value {
                self.collections.removeAll()
            } else {
                collections = audioPlayerViewModel.fetchCollectionByBeaconId(id: audioPlayerViewModel.beaconScanner.closestBeacon?.uuid.uuidString.lowercased() ?? "")
            }
        }
    }
}

#Preview {
    FindAuditagView(isExploring: .constant(false))
}
