//
//  SelectLocationView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 18/11/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct SelectLocationView: View {
    @State private var isVisible = false
    @State private var collections: [Collections] = []
    @State private var beacons: [DetectedBeacon] = []
    @State private var selectedBeaconId: String = ""
    @State private var initializeData = false
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    @StateObject private var playlistPlayerViewModel: PlaylistPlayerViewModel = PlaylistPlayerViewModel()
    @EnvironmentObject var beaconScanner: IBeaconDetector
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 16) {
                        if !beacons.isEmpty && self.initializeData {
                            Spacer()
                            Text("\(beacons.count) booth terdekat")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.subheadline)
                                .padding(.bottom, 2)
                                .foregroundColor(.gray)
                            
                            ForEach(Array(beacons.enumerated()), id: \.offset) { idx, beacon in
                                if !collections.isEmpty {
                                    if let collection = collections.first(where: { $0.beaconId == beacon.uuid }) {
                                        NavigationLink(destination:
                                                        PlaylistView(
                                                            isExploring: .constant(true),
                                                            collections: Binding(get: { collections.first(where: { $0.beaconId == beacon.uuid }) }, set: { _ in }),
                                                            selectedBeaconId: .constant(beacon.uuid)
                                                        )
                                                            .navigationBarHidden(true)
                                                            .environmentObject(audioPlayerViewModel)
                                                            .environmentObject(beaconScanner)
                                                            .environmentObject(playlistPlayerViewModel)
                                                            .onAppear {
                                                                beaconScanner.stopMonitoring()
                                                            }
                                                       
                                        ) {
                                            VStack(alignment: .leading){
                                                HStack {
                                                    WebImage(url: URL(string: collection.icon))
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 74, height: 74)
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(collection.roomId)
                                                            .font(.footnote)
                                                            .padding(.horizontal, 6)
                                                        
                                                        Text(collection.name)
                                                            .font(.headline)
                                                            .padding(.horizontal, 6)
                                                        
                                                        Text(collection.category)
                                                            .font(.caption).italic()
                                                            .padding(.horizontal, 6)
                                                    }
                                                    .frame(width: 180, height: 54, alignment: .leading)
                                                    
                                                    HStack (spacing: 1) {
                                                        Spacer()
                                                        Text("< 3 m")
                                                            .font(.footnote)
                                                            .frame(width: 55)
                                                        Image(systemName: "chevron.forward")
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .foregroundColor(.gray)
                                                }
                                                Text(collection.longContents)
                                                    .font(.caption)
                                                    .multilineTextAlignment(.leading)
                                                    .padding(.top, 4)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 155)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.gray, lineWidth: 0.5)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        Spacer().frame(height: 10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 431)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(36)
                .shadow(radius: 5)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 150)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.4)) {
                        isVisible = true
                    }
                }
                .task {
                    await reloadCollections()
                }
            }
            .ignoresSafeArea()
            .onReceive(beaconScanner.$detectedMultilaterationBeacons.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)) { value in
                if value.count > 0 && value.count != self.beacons.count {
                    let newBeacons = Array(Set(value.sorted(by: { $0.estimatedDitance < $1.estimatedDitance }).prefix(3)))
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.beacons = newBeacons
                    }
                    
                }
            }
            .refreshable {
                await refreshData()
            }
        }
    }
    
    func refreshData() async {
        collections.removeAll()
        do {
            await reloadCollections()
        } catch {
            print(error)
        }
    }
    
    func reloadCollections() async {
        for beacon in beacons {
            Task {
                let collection = await audioPlayerViewModel.fetchCollectionByBeaconId(id: beacon.uuid)
                if !collection.isEmpty {
                    self.collections.append(collection[0])
                }
            }
        }
        self.initializeData = true
    }
}

#Preview {
    @Previewable var beaconScanner: IBeaconDetector = IBeaconDetector()
    
    SelectLocationView()
        .environmentObject(beaconScanner)
}
