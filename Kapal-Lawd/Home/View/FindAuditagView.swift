//
//  FindAuditagView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 16/10/24.
//

import SwiftUI

struct FindAuditagView: View {
    @Binding var isExploring: Bool
    @State private var isScanning = false
    @State private var cardOpacity = 0.0
    @State var pulseScan = Animation.easeOut(duration: 2).repeatForever(autoreverses: true)
    @State private var showModal = false
    @State private var isBack = false
    @StateObject private var beaconScanner: IBeaconDetector = IBeaconDetector()
    
    var body: some View {
        if isBack {
            SpotHomepageView(spotHomepage: .constant(false))
        } else {
            ZStack {
                Color("AppBlue").ignoresSafeArea()
                
                VStack {
                    Button(action: {
                        isBack = true
                        ButtonHaptic()
                    }, label: {
                        Image("BackButton")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 40)
                    })
                    Spacer()
                }
                
                Group {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color("AppWhite").opacity(0.2))
                                .frame(maxWidth: 70)
                                .scaleEffect(isScanning ? 0.7 : 2.4)
                                .animation(pulseScan.delay(0.6), value: isScanning)
                                .animation(.easeInOut(duration: 1), value: isScanning)
                            
                            Circle()
                                .fill(Color("AppWhite"))
                                .frame(width: 65, height: 65)
                                .padding(.top, 55)
                                .padding(.bottom, 55)
                            
                        }
                        .onAppear {
                            self.isScanning = true
                            withAnimation(.easeOut(duration: 0.8)) {
                                cardOpacity = 1.0
                            }
                        }
                        .onDisappear{
                            self.isScanning = false
                        }
                        
                        VStack {
                            Text("Memindai AudiTag™")
                                .bold()
                                .font(.title3)
                                .foregroundColor(Color("AppWhite"))
                                .padding(.bottom, 12)
                            
                            Text("Dekati booth dengan tanda")
                                .font(.callout)
                                .foregroundColor(Color("AppWhite"))
                                .multilineTextAlignment(.center)
                            
                            Text("Tersedia di Audium")
                                .font(.callout)
                                .italic()
                                .foregroundColor(Color("AppWhite"))
                                .multilineTextAlignment(.center)
                            
                            Image("BoothIcon")
                                .padding(.top, 16)
                        }
                        .frame(maxWidth: 313)
                    }
                }
                
                if showModal {
                    VStack {
                        Spacer()
                        SelectLocationView()
                            .environmentObject(beaconScanner)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                            .transition(.move(edge: .bottom))
                            .onDisappear {
                                showModal = false
                            }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .animation(.easeInOut, value: showModal)
                }
                
            }
            .onAppear() {
                self.beaconScanner.startMonitoring()
            }
            .onReceive(beaconScanner.$isFindBeacon) { isFind in
                if isFind && beaconScanner.detectedBeacons.count >= 1 {
                    showModal = true
                }
            }
        }
    }
}

#Preview {
    FindAuditagView(isExploring: .constant(false))
}
