//
//  SpotHomepageView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 15/10/24.
//

import SwiftUI

struct SpotHomepageView: View {
    
    @Binding var spotHomepage: Bool
    @State private var isExploring = false
    
    var body: some View {
        NavigationStack {
            if isExploring {
                FindAuditagView(isExploring: self.$isExploring)
            } else {
                Spacer()
                VStack (spacing: 16) {
                    VStack {
                        Image("logoaudium")
                    }
                    .frame(width: 313, alignment: .center)
                    
                    VStack (spacing: 12) {
                        Text("Pengalaman baru Anda dimulai di sini")
                            .italic()
                            .font(.body)
                            .foregroundColor(Color("AppText"))
                            .frame(width: 317)
                            .multilineTextAlignment(.center)
                        Text("Audium mengubah kunjungan pameran Anda, memungkinkan booth menjelaskan produknya sendiri dengan cara yang paling dekat dan personal.")
                            .font(.caption)
                            .foregroundColor(Color("AppText"))
                            .frame(width: 317)
                            .multilineTextAlignment(.center)
                    }
                    
                    
                    VStack {
                        Button(action: {
                            isExploring = true
                            ButtonHaptic()
                        }, label: {
                            Text("Mulai Memindai AudiTag™")
                                .foregroundColor(Color("ButtonText"))
                                .font(.body)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color("AppButton"))
                                .cornerRadius(86)
                        })
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: 310)
                .background(.white)
                .cornerRadius(36)
                .shadow(radius: 5)
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    SpotHomepageView(spotHomepage: .constant(false))
}
