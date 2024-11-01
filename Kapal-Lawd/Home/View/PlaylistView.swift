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
    @State var showAlert = false
    @State var list: [Playlist] = []
    
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject private var playlistPlayerViewModel: PlaylistPlayerViewModel
    @EnvironmentObject private var backgroundPlayerViewModel: BackgroundPlayerViewModel
    
    var body: some View {
        Group {
            NavigationStack {
                if self.audioPlayerViewModel.isBeaconFar {
                    VStack {
                        FindAuditagView(isExploring: self.$isExploring)
                            .onAppear{
                                playlistPlayerViewModel.playlistPlayerManager.removeTimeObserver()
                                playlistPlayerViewModel.resetAsset()
                            }
                    }
                } else {
                    VStack {
                        HStack {
                            Button(action:  {
                                showAlert = true
                                
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .frame(maxWidth: 28, maxHeight: 28)
                                    .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                                    .cornerRadius(86)
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
                            
                            Text("AudiTag Collections")
                                .frame(maxWidth: 283)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .padding(.trailing, 50)
                        
                        if !collections.isEmpty {
                            HStack (spacing: 16) {
                                Image("witjk") // TODO: NEED CHANGE HOW TO GET THE IMAGE
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack (alignment: .leading) {
                                    Text(collections[0].name)
                                        .fontWeight(.semibold)
                                    
                                    Text(collections[0].authoredBy)
                                        .font(.footnote)
                                    
                                    Text(formattedDate(collections[0].authoredAt))
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                }
                                .padding(.trailing, 36)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 80)
                            
                            VStack {
                                Text(collections[0].longContents)
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 108)
                            .padding(.top, 12)
                            .padding(.bottom, 12)
                            
                            VStack (spacing: 16) {
                                VStack (alignment: .leading) {
                                    Text("TRACKLIST")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 25, alignment: .topLeading)
                                
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
                                                    Image("sound")
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
                                    .onAppear {
                                        playlistPlayerViewModel.startPlayback(song: playlistPlayerViewModel.playlistPlayerManager.playlist[0].name)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        
        .onAppear{
            list = audioPlayerViewModel.fetchPlaylistByCollectionId(id: collections[0].uuid)
            playlistPlayerViewModel.playlistPlayerManager.playlist = list
        }
        .onReceive(audioPlayerViewModel.beaconScanner.$averageRSSI) { rssi in
            audioPlayerViewModel.handleRSSIChange(rssi)
        }
        .onReceive(audioPlayerViewModel.$backgroundSound) { song in
            if !backgroundPlayerViewModel.backgroundSoundManager.isBackgroundPlaying && song != "" {
                backgroundPlayerViewModel.startBackgroundSound(song: song)
            }
        }
    }
}

#Preview {
    PlaylistView(
        isExploring: .constant(false),
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
        )
    )
}
