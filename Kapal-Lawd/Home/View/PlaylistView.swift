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
    @StateObject private var playlistPlayerViewModel: PlaylistPlayerViewModel = PlaylistPlayerViewModel()
    @StateObject private var backgroundPlayerViewModel: BackgroundPlayerViewModel = BackgroundPlayerViewModel()
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @State var showAlert = false
    @State private var isBackgroundPlay = false
    @State private var list: [Playlist] = []
    @State var initializeData: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if !initializeData {
                ProgressView()
            } else {
                if collections != nil {
                    ZStack(alignment: .topLeading) {
                        VStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(
                                    WebImage(url: URL(string: collections!.appBanner))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width, height: 182)
                                        .ignoresSafeArea()
                                )
                        }
                    }
                    
                    VStack(alignment: .center, spacing: 16) {
                        HStack (alignment: .top, spacing: 16) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 100, height: 100)
                                .background(
                                    WebImage(url: URL(string: collections!.icon))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                )
                            
                            VStack (alignment: .leading, spacing: 2) {
                                Text(collections!.roomId)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                Text(collections!.name)
                                    .fontWeight(.bold)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("oleh \(collections!.authoredBy)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                Text(collections!.category)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                HStack(alignment: .center) {
                                    Button(action: {
                                        if let url = URL(string: collections!.appUrl) {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text("Buka di App Store")
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(Color.blue)
                                            .cornerRadius(20)
                                    }
                                    .frame(height: 48)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let url = URL(string: collections!.instagram) {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Image(systemName: "network")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 29, height: 22)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(0)
                            }
                            .padding(.trailing, 24)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 118)
                    }
                    
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
                            list: $list,
                            isExploring: .constant(false)
                        )
                        .environmentObject(playlistPlayerViewModel)
                        .environmentObject(audioPlayerViewModel)
                        .environmentObject(backgroundPlayerViewModel)
                    }
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
        .onAppear{
            Task {
                self.list = await audioPlayerViewModel.fetchPlaylistByCollectionId(id: collections!.uuid)
                self.initializeData = true
            }
        }
        .threeOptionAlert(
            isPresented: $showAlert,
            title: DefaultContent.titleAlertDistance.rawValue,
            message: DefaultContent.messageAlertDistance.rawValue,
            option1: (
                text: DefaultContent.firstOption.rawValue,
                action: {
                    self.isExploring = false
                    playlistPlayerViewModel.stopPlayback()
                    backgroundPlayerViewModel.stopBackground()
                    dismiss()
                }
            ),
            option2: (
                text: DefaultContent.secondOption.rawValue,
                action: {
                    self.showAlert = false
                }
            )
        )
        .onReceive(playlistPlayerViewModel.playlistPlayerManager.$isPlaying)
        { isPlaying in
            if !isPlaying && list.count-1 == playlistPlayerViewModel.playlistPlayerManager.currentPlaylistIndex {
                self.showAlert = true
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
                uuid: "1be649c9-c897-4f62-bc97-895eef69d46b",
                roomId: "Section-1",
                name: "Dynamic Lines of Life",
                beaconId: "9d38c8b0-77f8-4e23-8dba-1546c4d035a4",
                icon: "https://drive.google.com/uc?id=1BPMUA3QNDFIhSm2vaJs6FC5VZQcNBZQJ",
                category: "Social Impact",
                appUrl: "https://apple.co/3UUZOEJ",
                instagram: "https://www.instagram.com/audiumexperience?igsh=ZjB6OHd6aTY5NG92",
                longContents: "In this section, visitors are introduced to Galeri Zen1—a sanctuary born from the passion of an art enthusiast with over a decade of experience. The gallery serves as a hub for both local and international contemporary artists, featuring a futuristic, minimalist, and industrial interior design. Additionally, visitors are introduced to the Audium App, an innovative technology that provides automatic audio narratives to enhance the visiting experience.",
                shortContents: "Experience the evolution of modern art.",
                authoredBy: "Audium",
                authoredAt: "2024-10-10",
                appBanner: "https://drive.google.com/uc?id=1Va4Jr5896GKaZGpee0XvW0wb3np45TZS"
            )
        ),
        selectedBeaconId: .constant("9d38c8b0-77f8-4e23-8dba-1546c4d035a4")
    )
    .environmentObject(audioPlayerViewModel)
    .environmentObject(beaconScanner)
}
