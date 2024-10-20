//
//  PlayerView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 18/10/24.
//

import SwiftUI

struct PlayerView: View {
    
    @State private var trackBar = 0.0
    @State private var isPlaying = false
    @Binding var list: [Playlist]
    @State private var currentSecond: String = "00:00"
    @ObservedObject private var audioPlayerViewModel = AudioPlayerViewModel()
    @State private var isFirstPlay: Bool = true
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Spacer()
        ZStack {
            VStack {
                VStack {
                    Text(list[audioPlayerViewModel.audioVideoManager.currentPlaylistIndex].name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    ProgressView("", value: trackBar, total: 300)
                        .accentColor(Color("AppButton"))
                        .scaleEffect(x: 1, y: 1.5, anchor: .bottom)
                    
                    HStack {
                        Text(currentSecond).font(.subheadline)
                        Spacer()
                        Text(list[audioPlayerViewModel.audioVideoManager.currentPlaylistIndex].duration).font(.subheadline)
                    }
                    .foregroundColor(.gray)
                    
                    HStack (spacing: 16) {
                        Button(action:  {
                            audioPlayerViewModel.previousPlaylist()
                            if audioPlayerViewModel.audioVideoManager.currentPlaylistIndex > 0 {
                                self.trackBar = 0.0
                            }
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
                                self.isPlaying.toggle()
                                
                                if self.isPlaying {
                                    if self.isFirstPlay {
                                        audioPlayerViewModel.startPlayback(song: list[audioPlayerViewModel.audioVideoManager.currentPlaylistIndex].name)
                                        self.isFirstPlay = false
                                    } else {
                                        audioPlayerViewModel.resumePlayback()
                                    }
                                    
                                } else {
                                    audioPlayerViewModel.pausePlayback()
                                }
                            }, label:  {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                            })
                        }
                        
                        Button(action:  {
                            
                        }, label:  {
                            Image(systemName: "15.arrow.trianglehead.clockwise")
                                .foregroundColor(Color("AppPlayer"))
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action:  {
                            audioPlayerViewModel.nextPlaylist()
                            if audioPlayerViewModel.audioVideoManager.currentPlaylistIndex < list.count - 1 {
                                self.trackBar = 0.0
                            }
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
        .onReceive(timer) { _ in
            if isPlaying && trackBar < convertToSeconds(from: list[audioPlayerViewModel.audioVideoManager.currentPlaylistIndex].duration)! {
                trackBar += 0.1
                self.currentSecond = convertSecondsToTimeString(seconds: trackBar)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 174)
        .background(Color.white)
        .cornerRadius(36)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
    }
}

extension PlayerView {
    func convertSecondsToTimeString(seconds: Double) -> String {
        let totalMinutes = Int(seconds) / 60
        let totalSeconds = Int(seconds) % 60
        
        let timeString = String(format: "%02d:%02d", totalMinutes, totalSeconds)
        return timeString
    }
    
    func convertToSeconds(from timeString: String) -> Double? {
        // Split the string by the decimal point
        let components = timeString.split(separator: ":")
        
        // Ensure we have exactly 2 components: minutes and seconds
        guard components.count == 2,
              let minutes = Double(components[0]), // Convert the minutes part
              let seconds = Double(components[1])  // Convert the seconds part
        else {
            return nil // Return nil if conversion fails
        }
        
        // Calculate total seconds
        let totalSeconds = (minutes * 60) + seconds
        return totalSeconds
        
    }
}

#Preview {
    PlayerView(list: .constant([Playlist(
        uuid: "123e4567-e89b-12d3-a456-426614174000",
        collectionId: "collection-001",
        name: "My Playlist",
        duration: "04:30"
    )]))
}
