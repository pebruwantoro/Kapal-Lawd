//
//  PlaylistView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 16/10/24.
//

import SwiftUI

struct PlaylistView: View {
    
    @Binding var isExploring: Bool
    @ObservedObject private var audioPlayerViewModel = AudioPlayerViewModel()
    @Binding var collections: [Collections]
    @State var isMusicPlaying: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action:  {
                        isExploring = true
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .frame(maxWidth: 28, maxHeight: 28)
                            .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                            .cornerRadius(86)
                    })
                    
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
                        
                        let playlists = audioPlayerViewModel.fetchPlaylistByCollectionId(id: collections[0].uuid)
                        
                        if !playlists.isEmpty {
                            List(playlists, id: \.uuid) { playlist in
                                HStack {
                                    VStack (alignment: .leading) {
                                        Text(playlist.name)
                                            .bold()
                                        Text(playlist.duration)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action:  {
                                        if audioPlayerViewModel.audioVideoManager.isPlaying {
                                            self.isMusicPlaying = false
                                            audioPlayerViewModel.stopPlayback()
                                        } else {
                                            self.isMusicPlaying = true
                                            audioPlayerViewModel.startPlayback(song: playlist.name)
                                        }
                                    }, label: {
                                        if self.isMusicPlaying {
                                            Image("sound")
                                                .foregroundColor(Color("AppLabel"))
                                        } else {
                                            Image(systemName: "play")
                                                .foregroundColor(Color("AppLabel"))                                            }
                                    })
                                    
                                }.frame(maxWidth: .infinity, maxHeight: 60)
                            }.padding(.bottom, 16)
                        }
                    }.padding(.bottom, 16)
                    
                    VStack {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 174)
                    .background(Color.white)
                    .cornerRadius(36)
                    .shadow(radius: 5)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

extension PlaylistView {
    func formattedDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let newDate = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM yyyy"
            
            let formattedDateString = outputFormatter.string(from: newDate)
            print("format masa depan",formattedDateString)
            return formattedDateString
        }
        
        return ""
    }}



#Preview {
    PlaylistView(isExploring: .constant(false), collections: .constant([]))
}
