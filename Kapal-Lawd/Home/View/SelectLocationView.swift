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
    @State private var isBeaconCollected = false
    @State private var selectedBeaconId: String = ""
    @State private var isUserPressButton = false
    @EnvironmentObject var beaconScanner: IBeaconDetector
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    
    var body: some View {
        if self.isUserPressButton {
            
            PlaylistView(
                isExploring: .constant(true),
                collections: Binding(get: { collections.first(where: { $0.beaconId == self.$selectedBeaconId.wrappedValue }) }, set: { _ in }),
                selectedBeaconId: self.$selectedBeaconId
            )
            .onAppear {
                print("selected beacon on select view: \(self.selectedBeaconId)")
                print("collections on select view: \(collections.filter({ $0.beaconId == self.$selectedBeaconId.wrappedValue }))")
                
            }
            .onDisappear {
                self.isUserPressButton = false
            }
            .environmentObject(audioPlayerViewModel)
            .environmentObject(beaconScanner)
        } else {
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    if !beacons.isEmpty {
                        Spacer()
                        Text("\(beacons.count) booth terdekat")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .padding(.bottom, 2)
                            .foregroundColor(.gray)
                        
                        ForEach(Array(beacons.enumerated()), id: \.offset) { idx, beacon in
                            if !collections.isEmpty {
                                if let collection = collections.first(where: { $0.beaconId == beacon.uuid }) {
                                    Button(action: {
                                        ButtonHaptic()
                                        self.isUserPressButton = true
                                        self.selectedBeaconId = beacon.uuid
                                    }) {
                                        VStack(alignment: .leading){
                                            HStack {
                                                WebImage(url: URL(string: collection.icon))
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 74, height: 74)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(collection.roomId + "--" + collection.beaconId)
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
                                                    Text(String(format: "%.2f m", beacon.averageDistance))
                                                        .font(.footnote)
                                                        .frame(width: 38)
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
                .onAppear {
                    if !self.beacons.isEmpty {
                        for beacon in beacons {
                            Task {
                                let collection = await audioPlayerViewModel.fetchCollectionByBeaconId(id: beacon.uuid)

                                self.collections.append(collection[0])
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(beaconScanner.$detectedMultilaterationBeacons) { value in
                if value.count > 0 {
                    self.beacons = value
                }
            }
        }
    }
}

#Preview {
    @Previewable var beaconScanner: IBeaconDetector = IBeaconDetector()
    
    SelectLocationView()
        .environmentObject(beaconScanner)
}
