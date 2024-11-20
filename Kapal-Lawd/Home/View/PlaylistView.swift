//
//  PlaylistView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 16/10/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct PlaylistView: View {
    @Binding var isExploring: Bool
    @Binding var collections: Collections?
    @Binding var selectedBeaconId: String
    @State private var selectedBeacon: DetectedBeacon?
    @StateObject private var playlistPlayerViewModel: PlaylistPlayerViewModel = PlaylistPlayerViewModel()
    @StateObject private var backgroundPlayerViewModel: BackgroundPlayerViewModel = BackgroundPlayerViewModel()
    @EnvironmentObject private var beaconScanner: IBeaconDetector
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @State var showAlert = false
    @State private var isBackgroundPlay = false
    @State private var isBack = false
    @State private var list: [Playlist] = []
    
    var body: some View {
        Group {
            NavigationStack {
                if self.isBack {
                    VStack {
                        FindAuditagView(isExploring: self.$isExploring)
                            .onAppear {
                                playlistPlayerViewModel.playlistPlayerManager.removeTimeObserver()
                                playlistPlayerViewModel.resetAsset()
                                backgroundPlayerViewModel.stopBackground()
                                self.collections = nil
                                self.list.removeAll()
                                self.isBack = false
                            }
                    }
                    
                } else {
                    ZStack {
                        VStack {
                            ZStack(alignment: .topLeading) {
                                VStack {
                                    Image("headertitle")
                                        .resizable()
                                        .scaledToFit()
                                        .ignoresSafeArea()
                                    Spacer()
                                }
                                
                                HStack {
                                    Button(action:  {
                                        showAlert = true
                                        ButtonHaptic()
                                    }, label: {
                                        Image("BackButton")
                                            .frame(maxWidth: 28, maxHeight: 28)
                                    })
                                    .alert(isPresented: $showAlert) {
                                        Alert(
                                            title: Text("Keluar dari Booth?"),
                                            message: Text("Kamu terdeteksi keluar dari area booth Audium. Kembali ke halaman scanning?"),
                                            primaryButton: .destructive(Text("Keluar dari Booth")) {
                                                self.isExploring = false
                                                self.isBack = true
                                                playlistPlayerViewModel.stopPlayback()
                                                backgroundPlayerViewModel.stopBackground()
                                            },
                                            secondaryButton: .default(Text("Tetap di Booth")) {
                                            }
                                        )
                                    }
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                .padding(.top, 16)
                                .padding(.trailing, 50)
                                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .topLeading)
                                
                            }
                            
                            if collections != nil {
                                HStack (spacing: 16) {
                                    WebImage(url: URL(string: collections!.icon))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack (alignment: .leading) {
                                        Text(collections!.name)
                                            .fontWeight(.semibold)
                                            .lineLimit(nil)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: 350, alignment: .leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Text(collections!.authoredBy)
                                            .font(.footnote)
                                        
                                        Text(collections!.beaconId)
                                            .font(.footnote)
                                        
                                        Text(selectedBeaconId)
                                            .font(.footnote)
                                        
                                        //TODO: date ganti jadi segmen tim
                                        Text(formattedDate(collections!.authoredAt))
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .padding(.top, 8)
                                        
                                        HStack {
                                            Button(action: {
                                                if let url = URL(string: collections!.appUrl) {
                                                    UIApplication.shared.open(url)
                                                }
                                            }) {
                                                Text("Buka di App Store")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 12)
                                                    .padding(.horizontal, 24)
                                                    .background(Color.blue)
                                                    .cornerRadius(20)
                                                    .frame(width: 48, height: 48)
                                            }
                                            
                                            Button(action: {
                                                if let url = URL(string: collections!.instagram) {
                                                    UIApplication.shared.open(url)
                                                }
                                            }) {
                                                Image("instagramIcon")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 48, height: 48)
                                                    .padding(.trailing, 12)
                                            }
                                        }
                                    }
                                    .padding(.trailing, 36)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 100)
                                
                                VStack {
                                    ScrollView {
                                        Text(collections!.longContents)
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
                                                    playlistPlayerViewModel.startPlayback(song: playlist.name, url: playlist.url)
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
                                    PlayerView(
                                        isPlaying: $playlistPlayerViewModel.playlistPlayerManager.isPlaying,
                                        list: $list
                                    )
                                        .environmentObject(playlistPlayerViewModel)
                                        .environmentObject(audioPlayerViewModel)
                                        .environmentObject(backgroundPlayerViewModel)
                                        .environmentObject(beaconScanner)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .onAppear {
                            if !self.isBackgroundPlay {
                                if let beacon = audioPlayerViewModel.fetchBeaconById(id: self.selectedBeaconId) {
                                    self.isBackgroundPlay = true
                                    backgroundPlayerViewModel.startBackgroundSound(song: beacon.backgroundSound)
                                }
                            }
                        }
                        .onDisappear {
                            self.isBackgroundPlay = false
                            backgroundPlayerViewModel.stopBackground()
                            
                        }
                    }
                    .onAppear {
                        print("selected beacon on playlist view: \(self.selectedBeaconId)")
                        print("collections on playlist view: \(self.collections!)")
                    }
                    .onAppear{
                        Task {
                            self.list = await audioPlayerViewModel.fetchPlaylistByCollectionId(id: collections!.uuid)
                        }
                    }
                }
            }
            .onReceive(beaconScanner.$detectedMultilaterationBeacons) { beacons in
                if let tempBeacon = beacons.first(where: { $0.uuid == self.selectedBeaconId }) {
                    self.selectedBeacon = tempBeacon
                }
                
                if self.selectedBeacon != nil {
                    if self.selectedBeacon!.averageDistance > Beacon.maxInRange.rawValue {
                        print("beacon to far with distance: \(self.selectedBeacon!.averageDistance)")
                    } else {
                        print("beacon in range with distance: \(self.selectedBeacon!.averageDistance)")
                    }
                }
            }
        }
    }
}

#Preview {
    @ObservedObject var beaconScanner: IBeaconDetector = IBeaconDetector()
    @ObservedObject var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    
    PlaylistView(
        isExploring: .constant(false),
        
        collections: .constant(
            Collections(
                uuid: "String",
                roomId: "String",
                name: "String",
                beaconId: "String",
                icon: "AppIcon",
                category: "Games",
                appUrl: "google.com",
                instagram: "test",
                longContents: "String",
                shortContents: "String",
                authoredBy: "String",
                authoredAt: "2024-10-10"
            )
        ),
        selectedBeaconId: .constant("")
    )
    .environmentObject(audioPlayerViewModel)
    .environmentObject(beaconScanner)
}
