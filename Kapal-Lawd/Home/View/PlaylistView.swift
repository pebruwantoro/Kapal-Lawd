//
//  PlaylistView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 16/10/24.
//

import SwiftUI

struct PlaylistView: View {
    @Binding var isExploring: Bool
    @Binding var collections: [Collections]
    @Binding var list: [Playlist]
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject private var playlistPlayerViewModel: PlaylistPlayerViewModel
    @EnvironmentObject private var backgroundPlayerViewModel: BackgroundPlayerViewModel
    @EnvironmentObject private var beaconScanner: IBeaconDetector
    @State var showAlert = false
    @State private var isBackgroundPlay = false
    
    var body: some View {
        Group {
            NavigationStack {
                if self.beaconScanner.isBeaconFar {
                    VStack {
                        FindAuditagView(isExploring: self.$isExploring)
                            .onReceive(beaconScanner.$isFindBeacon) { isFind in
                                if !isFind {
                                    playlistPlayerViewModel.playlistPlayerManager.removeTimeObserver()
                                    playlistPlayerViewModel.resetAsset()
                                    backgroundPlayerViewModel.stopBackground()
                                    self.collections.removeAll()
                                    self.list.removeAll()
                                }
                            }
                    }
                    
                } else {
                    ZStack {
                        VStack {
                            Image("headertitle")
                                .resizable()
                                .scaledToFit()
                                .ignoresSafeArea()
                            Spacer()
                        }
                        VStack {
                            HStack {
                                Button(action:  {
                                    showAlert = true
                                }, label: {
                                    Image("BackButton")
                                        .frame(maxWidth: 28, maxHeight: 28)
                                })
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("End Exploration Session"),
                                        message: Text("By stopping the session, your device will not perform AudiTag scanning"),
                                        primaryButton: .default(Text("Continue Exploration")) {
                                        },
                                        secondaryButton: .destructive(Text("End Session")) {
                                            isExploring = false
                                            playlistPlayerViewModel.stopPlayback()
                                            backgroundPlayerViewModel.stopBackground()
                                        }
                                    )
                                }
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .padding(.trailing, 50)
                            
                            if !collections.isEmpty {
                                HStack (spacing: 16) {
                                    Image("AppLogo") // TODO: NEED CHANGE HOW TO GET THE IMAGE
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack (alignment: .leading) {
                                        Text(collections[0].name)
                                            .fontWeight(.semibold)
                                            .lineLimit(nil)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: 350, alignment: .leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Text(collections[0].authoredBy)
                                            .font(.footnote)
                                        
                                        //TODO: date ganti jadi segmen tim
                                        Text(formattedDate(collections[0].authoredAt))
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .padding(.top, 8)
                                    }
                                    .padding(.trailing, 36)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 80)
                                
                                VStack {
                                    ScrollView {
                                        Text(collections[0].longContents)
                                            .font(.footnote)
                                            .padding(.horizontal, 8)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: 108)
                                .padding(.top, 12)
                                .padding(.bottom, 12)
                                
                                VStack (spacing: 16) {
                                    
                                    if !self.list.isEmpty {
                                        List($list, id: \.uuid) { $playlist in
                                            HStack {
                                                VStack (alignment: .leading) {
                                                    Text(playlist.name)
                                                        .bold()
                                                    Text(playlist.duration)
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    playlistPlayerViewModel.startPlayback(song: playlist.name)
                                                    ButtonHaptic()
                                                })
                                                {
                                                    if playlistPlayerViewModel.playlistPlayerManager.isPlaying && playlist.name == playlistPlayerViewModel.playlistPlayerManager.currentSongTitle {
                                                        Image("sounds")
                                                    } else {
                                                        Image(systemName: "play")
                                                            .foregroundColor(Color("AppLabel"))
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 60)
                                        }
                                        .listStyle(.plain)
                                        .padding(.bottom, 16)
                                    }
                                }.padding(.bottom, 16)
                                
                                if !self.list.isEmpty {
                                    PlayerView(isPlaying: $playlistPlayerViewModel.playlistPlayerManager.isPlaying, list: $list)
                                        .environmentObject(audioPlayerViewModel)
                                        .environmentObject(playlistPlayerViewModel)
                                        .environmentObject(backgroundPlayerViewModel)
                                        .environmentObject(beaconScanner)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .onReceive(beaconScanner.$isFindBeacon) { isFind in
                            delay(DefaultDelay.backSound.rawValue) {
                                if isFind && !isBackgroundPlay {
                                    if let beacon = audioPlayerViewModel.fetchBeaconById(id: (beaconScanner.closestBeacon?.uuid.uuidString.lowercased())!) {
                                        self.isBackgroundPlay = true
                                        backgroundPlayerViewModel.startBackgroundSound(song: beacon.backgroundSound)
                                    } else {
                                        self.isBackgroundPlay = false
                                        backgroundPlayerViewModel.stopBackground()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    @Previewable var playlistPlayerViewModel: PlaylistPlayerViewModel = PlaylistPlayerViewModel()
    @Previewable var backgroundPlayerViewModel: BackgroundPlayerViewModel = BackgroundPlayerViewModel()
    @Previewable var beaconScanner: IBeaconDetector = IBeaconDetector()
    
    PlaylistView(
        isExploring: .constant(true),
        collections: .constant(
            [
                Collections(
                    uuid: "String",
                    roomId: "String",
                    name: "String",
                    beaconId: "String",
                    longContents: "String",
                    shortContents: "String",
                    authoredBy: "String",
                    authoredAt: "2024-10-10"
                )
            ]
        ),
        list: .constant([
            Playlist(uuid: "", collectionId: "", name: "", duration: "")
        ])
    )
    .environmentObject(audioPlayerViewModel)
    .environmentObject(playlistPlayerViewModel)
    .environmentObject(backgroundPlayerViewModel)
    .environmentObject(beaconScanner)
}
