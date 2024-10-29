//
//  PlayerView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 18/10/24.
//

import SwiftUI

struct PlayerView: View {
    @Binding var trackBar: Double
    @Binding var isPlaying: Bool
    @Binding var list: [Playlist]
    @State private var currentSecond: String = "00:00"
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @State private var currentSong: String = ""
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Spacer()
        ZStack {
            VStack {
                VStack {
                    Text(self.currentSong)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    ProgressView("", value: self.trackBar, total: convertToSeconds(from: list[audioPlayerViewModel.audioVideoManager.currentPlaylistIndex].duration)!)
                        .accentColor(Color("AppButton"))
                        .scaleEffect(x: 1, y: 1.5, anchor: .bottom)
                    
                    HStack {
                        Text(self.currentSecond)
                            .font(.subheadline)
                        
                        Spacer()
                        Text(list[audioPlayerViewModel.audioVideoManager.currentPlaylistIndex].duration)
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
                    
                    HStack (spacing: 16) {
                        Button(action:  {
                            audioPlayerViewModel.previousPlaylist()
                            self.trackBar = 0.0
                        }, label:  {
                            Image(systemName: "backward")
                                .foregroundColor(Color("AppPlayer"))
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action:  {
                            
                        }, label:  {
                            Image(systemName: "15.arrow.trianglehead.counterclockwise")
                                .foregroundColor(Color("AppPlayer"))
                        })
                        .frame(width: 50, height: 50)
                        
                        ZStack {
                            Circle()
                                .foregroundColor(Color("AppPlayer"))
                            
                            Button(action:  {
                                if !self.isPlaying {
                                    audioPlayerViewModel.resumePlayback()
                                    self.isPlaying = true
                                } else {
                                    audioPlayerViewModel.pausePlayback()
                                    self.isPlaying = false
                                }
                            }, label:  {
                                Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                            })
                        }
                        .frame(width: 50, height: 50)
                        
                        Button(action:  {
                        }, label:  {
                            Image(systemName: "15.arrow.trianglehead.clockwise")
                                .foregroundColor(Color("AppPlayer"))
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action:  {
                            audioPlayerViewModel.nextPlaylist()
                            self.trackBar = 0.0
                        }, label:  {
                            Image(systemName: "forward")
                                .foregroundColor(Color("AppPlayer"))
                        })
                        .frame(width: 50, height: 50)
                    }
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: 174)
        .background(Color.white)
        .cornerRadius(36)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
        .onReceive(audioPlayerViewModel.audioVideoManager.$currentSongTitle) { song in
            if let audio = song {
                self.currentSong = audio
            }
        }
        .onReceive(audioPlayerViewModel.audioVideoManager.$currentTimeInSeconds) { time in
            self.currentSecond = convertSecondsToTimeString(seconds: time)
            self.trackBar = time
        }
    }
}

#Preview {
    PlayerView(trackBar: .constant(0.0), isPlaying: .constant(true), list: .constant([Playlist(
        uuid: "123e4567-e89b-12d3-a456-426614174000",
        collectionId: "collection-001",
        name: "My Playlist",
        duration: "04:30"
    )]))
}
