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
    @State private var collections: [Collections] = []
    @State private var playlists: [Playlist] = []
    @State var pulseScan = Animation.easeOut(duration: 2).repeatForever(autoreverses: true)
    //    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    //    @StateObject private var playlistPlayerViewModel: PlaylistPlayerViewModel = PlaylistPlayerViewModel()
    //    @StateObject private var backgroundPlayerViewModel: BackgroundPlayerViewModel = BackgroundPlayerViewModel()
    //    @StateObject private var interactionPlayerViewModel: InteractionPlayerViewModel = InteractionPlayerViewModel()
    @StateObject private var beaconScanner: IBeaconDetector = IBeaconDetector()
    @State private var isPlayInteraction = false
    @State private var isContentReady = false
    @State private var showModal = true
    @State private var isBack = false
    
    var body: some View {
        if isBack {
            SpotHomepageView(spotHomepage: .constant(false))
        } else {
            ZStack {
                Color("AppBlue").ignoresSafeArea()
                
                VStack {
                    Button(action: {
                        isBack = true
                        ButtonHaptic()
                    }, label: {
                        Image("BackButton")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 40)
                    })
                    Spacer()
                }
                
                Group {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color("AppWhite").opacity(0.2))
                                .frame(maxWidth: 70)
                                .scaleEffect(isScanning ? 0.7 : 2.4)
                                .animation(pulseScan.delay(0.6), value: isScanning)
                                .animation(.easeInOut(duration: 1), value: isScanning)
                            
                            Circle()
                                .fill(Color("AppWhite"))
                                .frame(width: 65, height: 65)
                                .padding(.top, 55)
                                .padding(.bottom, 55)
                            
                        }
                        .onAppear {
                            self.isScanning = true
                            withAnimation(.easeOut(duration: 0.8)) {
                                cardOpacity = 1.0
                            }
                        }
                        
                        VStack {
                            Text("Memindai AudiTag™")
                                .bold()
                                .font(.title3)
                                .foregroundColor(Color("AppWhite"))
                                .padding(.bottom, 12)
                            
                            Text("Dekati booth dengan tanda")
                                .font(.callout)
                                .foregroundColor(Color("AppWhite"))
                                .multilineTextAlignment(.center)
                            
                            Text("Tersedia di Audium")
                                .font(.callout)
                                .italic()
                                .foregroundColor(Color("AppWhite"))
                                .multilineTextAlignment(.center)
                            
                            Image("BoothIcon")
                                .padding(.top, 16)
                        }
                        .frame(maxWidth: 313)
                    }
                }
                
            }
            //            .onReceive(beaconScanner.$isFindBeacon) { isFind in
            //                if !isFind {
            //                    self.playlistPlayerViewModel.stopPlayback()
            //                    self.backgroundPlayerViewModel.stopBackground()
            //                    self.beaconScanner.startMonitoring()
            //                    self.playlistPlayerViewModel.playlistPlayerManager.removeTimeObserver()
            //                    self.isContentReady = false
            //                } else {
            //                    Task {
            //                        let id = beaconScanner.closestBeacon?.uuid.uuidString.lowercased() ?? ""
            //                        let collectionsResult = await audioPlayerViewModel.fetchCollectionByBeaconId(id: id)
            //                        if collectionsResult.count > 0 {
            //                            let playlistsResult = await audioPlayerViewModel.fetchPlaylistByCollectionId(id: collectionsResult[0].uuid)
            //                            await MainActor.run {
            //                                self.collections = collectionsResult
            //                                self.playlists = playlistsResult
            //                                self.isContentReady = true
            //                                self.showModal = true
            //                            }
            //                        }
            //                    }
            //                }
            //            }
            .onReceive(beaconScanner.$isFindBeacon) {isFind in
                if isFind {
                    showModal = true
                }
            }
            .sheet(isPresented: $showModal) {
                SelectLocationView()
                    .environmentObject(beaconScanner)
                //                    .frame(maxWidth: .infinity)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    FindAuditagView(isExploring: .constant(false))
}

//PlaylistView(isExploring: self.$isExploring, collections: $collections, list: $playlists)
//                            .onReceive(beaconScanner.$isFindBeacon) { value in
//                                if !isPlayInteraction {
//                                    interactionPlayerViewModel.startInteractionSound(song: DeafultSong.interaction.rawValue)
//                                    isPlayInteraction = value
//                                }
//                            }
//                            .environmentObject(audioPlayerViewModel)
//                            .environmentObject(playlistPlayerViewModel)
//                            .environmentObject(backgroundPlayerViewModel)
//                            .environmentObject(beaconScanner)
