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
    @State private var selectedCollection: [Collections] = []
    @State private var isUserPressButton = false
    @EnvironmentObject private var beaconScanner: IBeaconDetector
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
    
    
    var body: some View {
        if self.isUserPressButton {
            if self.selectedCollection.isEmpty {
                
                ProgressView()
                    .onAppear{
                        print("selected collection is empty")
                        let data = collections.filter({ $0.beaconId == self.selectedBeaconId })
                        selectedCollection = data
                    }
                    .onDisappear{
                        self.isUserPressButton = false
                    }
            } else {
                PlaylistView(
                    isExploring: .constant(true),
                    collections: self.$selectedCollection,
                    selectedBeaconId: self.$selectedBeaconId
                )
                .environmentObject(audioPlayerViewModel)
                .environmentObject(beaconScanner)
                .onAppear{
                    print("selected collection is not empty")
                    
                }
            }
            
        } else {
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    ScrollView {
                        
                        VStack(spacing: 16) {
                            if !beacons.isEmpty {
                                Spacer()
                                Text("\(beacons.count) booth terdekat")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.subheadline)
                                    .padding(.bottom, 2)
                                    .foregroundColor(.gray)
                                
                                ForEach(Array(beacons.enumerated()), id: \.offset) { idx, beacon in
                                    if collections.isEmpty {
                                        ProgressView()
                                            .onAppear{
                                                Task {
                                                    let collection = await audioPlayerViewModel.fetchCollectionByBeaconId(id: beacon.uuid)
                                                    
                                                    self.collections.append(collection[0])
                                                }
                                            }
                                    } else if collections.count == beacons.count {
                                        Button(action: {
                                            ButtonHaptic()
                                            print("Button tapped for beacon id: \(beacon.uuid), & collection id: \(String(describing: collections.first{ $0.beaconId == beacon.uuid }?.uuid))")
                                            self.isUserPressButton = true
                                            self.selectedBeaconId = beacon.uuid
                                        }) {
                                            VStack(alignment: .leading){
                                                HStack {
                                                    WebImage(url: URL(string: collections[idx].icon))
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 74, height: 74)
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(collections[idx].roomId)
                                                            .font(.footnote)
                                                            .padding(.horizontal, 6)
                                                        
                                                        Text(collections[idx].name)
                                                            .font(.headline)
                                                            .padding(.horizontal, 6)
                                                        
                                                        Text(collections[idx].category)
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
                                                Text(collections[idx].longContents)
                                                    .font(.caption)
                                                    .multilineTextAlignment(.leading)
                                                    .padding(.top, 4)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 155)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .padding(.top, 8)
                                            .padding(.bottom, 8)
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
                    }
                    //                    Spacer().frame(height: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .padding(0)
                
            }
            .padding()
            .background(Color.white)
            .onReceive(beaconScanner.$isFindBeacon) { isFind in
                if isFind && !self.isBeaconCollected {
                    self.beacons = beaconScanner.detectedMultilaterationBeacons
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
