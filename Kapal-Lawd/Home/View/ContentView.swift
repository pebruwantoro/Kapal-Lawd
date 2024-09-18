//
//  ContentView.swift
//  Kapal Lawd
//
//  Created by Doni Pebruwantoro on 18/09/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var beaconManager = IBeaconDetector()
    @State private var proximityText: String = "No Beacon Detected"
    @State private var ghostAppear: Bool = false

    var body: some View {
        VStack {
            Text(proximityText) // Menampilkan teks berdasarkan proximity
                .padding()
                .font(.headline)

            .onReceive(beaconManager.$proximity) { proximity in
                print(proximity.rawValue)
                switch proximity {
                case .immediate:
                    proximityText = "Dekat sekali"
                    ghostAppear = true
                case .near:
                    proximityText = "Dekat"
                    ghostAppear = false
                case .far:
                    proximityText = "Jauh"
                    ghostAppear = false
                case .unknown:
                    proximityText = "Tidak diketahui"
                    ghostAppear = false
                @unknown default:
                    proximityText = "Tidak diketahui"
                    ghostAppear = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
