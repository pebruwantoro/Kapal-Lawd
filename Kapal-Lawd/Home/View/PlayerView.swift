//
//  PlayerView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 18/10/24.
//

import SwiftUI

struct PlayerView: View {
    @Binding var isPlaying: Bool
    @Binding var list: [Playlist]
    @Binding var isExploring: Bool
    @State private var currentSong: String = ""
    @State private var isFirstPlaylistPlay: Bool = false
    @EnvironmentObject private var playlistPlayerViewModel: PlaylistPlayerViewModel
    @EnvironmentObject private var backgroundPlayerViewModel: BackgroundPlayerViewModel
    @Environment(\.dismiss) var dismiss
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Spacer()
        ZStack {
            VStack  {
                if !list.isEmpty {
                    VStack {
                        HStack (spacing: 16) {
                            Text(self.currentSong)
                                .frame(maxWidth: 214, alignment: .leading)
                                .font(.body).bold()
                                .foregroundColor(Color("AppText"))
                            
                            Button(action:  {
                                playlistPlayerViewModel.nextPlaylist()
                                ButtonHaptic()
                            }, label:  {
                                Image(systemName: "forward")
                                    .foregroundColor(Color("AppPlayer"))
                            })
                            .frame(width: 50, height: 50)
                            
                            ZStack {
                                Circle()
                                    .foregroundColor(Color("AppPlayer"))
                                
                                Button(action:  {
                                    if !self.isPlaying {
                                        playlistPlayerViewModel.resumePlayback()
                                        self.isPlaying = true
                                        ButtonHaptic()
                                    } else {
                                        playlistPlayerViewModel.pausePlayback()
                                        self.isPlaying = false
                                        ButtonHaptic()
                                    }
                                }, label:  {
                                    Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                                        .foregroundColor(.white)
                                })
                            }
                            .frame(width: 50, height: 50)
                        }
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Button(action: {
                            self.isExploring = false
                            playlistPlayerViewModel.stopPlayback()
                            backgroundPlayerViewModel.stopBackground()
                            dismiss()
                            
                        }, label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Pindah ke Booth Lain")
                            }
                            .foregroundColor(Color("AppBlue"))
                            .font(.body)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color("ButtonGrey"))
                            .cornerRadius(86)
                        })
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 112)
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: 174)
        .background(Color.white)
        .cornerRadius(36)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
        .onDisappear {
            self.isFirstPlaylistPlay = false
            self.isPlaying = false
            playlistPlayerViewModel.stopPlayback()
            playlistPlayerViewModel.playlistPlayerManager.removeTimeObserver()
        }
        .onAppear {
            if !self.isFirstPlaylistPlay {
                self.isFirstPlaylistPlay = true
                playlistPlayerViewModel.startPlayback(song: list[0].name, url: list[0].url)
            }
            
            self.playlistPlayerViewModel.playlistPlayerManager.playlist = list
            self.currentSong = playlistPlayerViewModel.playlistPlayerManager.currentSongTitle ?? "none"
            
        }
        .onReceive(playlistPlayerViewModel.playlistPlayerManager.$currentSongTitle) { song in
            if let audio = song {
                self.currentSong = audio
            }
        }
    }
}

#Preview {
//    @ObservedObject var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    @ObservedObject var playlistPlayerViewModel: PlaylistPlayerViewModel = PlaylistPlayerViewModel()
    @ObservedObject var backgroundPlayerViewModel: BackgroundPlayerViewModel = BackgroundPlayerViewModel()
    
    PlayerView(
        isPlaying: .constant(true),
        list: .constant(
            [
                Playlist(
                    uuid: "123e4567-e89b-12d3-a456-426614174000",
                    collectionId: "collection-001",
                    name: "My Playlist",
                    duration: "04:30",
                    url: ""
                )
            ]
        ),
        isExploring: .constant(false)
    )
    .environmentObject(playlistPlayerViewModel)
    .environmentObject(backgroundPlayerViewModel)
}
