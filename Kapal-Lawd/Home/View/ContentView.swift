//
//  ContentView.swift
//  Kapal Lawd
//
//  Created by Doni Pebruwantoro on 18/09/24.
//


import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var beaconScanner = IBeaconDetector()
    @State private var proximityText: String = "No Beacon Detected"
    @StateObject private var ap = AudioPlayerViewModel()
    
    var body: some View {
        VStack {
            Text(proximityText)
                .padding()
                .font(.headline)
                .onReceive(beaconScanner.$proximity) { proximity in
                    print(proximity.rawValue)
                    switch proximity {
                    case .immediate:
                        proximityText = "Dekat sekali"
                        if !ap.isPlaying {
                            ap.startPlayback(songTitle: "dreams")  // Ganti dengan lagu yang diinginkan
                        }
                    case .near:
                        proximityText = "Dekat"
                        if !ap.isPlaying {
                            ap.startPlayback(songTitle: "dreams")
                        }
                    case .far:
                        proximityText = "Jauh"
                        ap.stopPlayback()
                    case .unknown:
                        proximityText = "Tidak diketahui"
                        ap.stopPlayback()
                    @unknown default:
                        proximityText = "Tidak diketahui"
                        ap.stopPlayback()
            Text("Now Playing: \(avManager.currentSongTitle ?? "None")")

            // Audio Player Controls
            HStack {
                Button(action: {
                    if avManager.isPlaying {
                        avManager.pausePlayback()
                    } else {
                        avManager.startPlayback(songTitle: "welcome")
                    }
                }
        }
        .onAppear {
            configureAudioSession()
        }
    }
    
    // Mengonfigurasi sesi audio agar bisa diputar di latar belakang
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            // Gunakan kategori playback untuk memutar audio di latar belakang
            try session.setCategory(.playback, mode: .default)

            // Aktifkan sesi audio
            try session.setActive(true)
            
            print("Audio session berhasil diatur.")
        } catch {
            print("Gagal mengatur sesi audio: \(error.localizedDescription)")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
