//
//  OnboardingSecondView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 14/11/24.
//

import SwiftUI

struct OnboardingSecondView: View {
    
    @Binding var secondOnboarding: Bool
    @State private var thirdOnboarding = false
    
    var body: some View {
        if thirdOnboarding {
            OnboardingThirdView(thirdOnboarding: self.$thirdOnboarding)
        } else {
            Spacer()
            NavigationStack {
                Image("imagetwo")
                    .resizable().scaledToFill()
                    .frame(width: 370, height: 210)
                    .clipShape(HalfRoundedRectangle(cornerRadius: 36))
                    .offset(y: -38)
                
                VStack {
                    Text("Bluetooth dan Lokasi")
                        .font(.title).bold()
                        .frame(width: 313, alignment: .leading)
                    
                    VStack (spacing: 16) {
                        Text("Nyalakan bluetooth dan izinkan akses lokasi.")
                            .italic()
                            .font(.subheadline)
                            .frame(width: 313, alignment: .leading)
                        
                        
                        Text("Audium menggunakan Bluetooth dan layanan lokasi untuk mendeteksi lokasi untuk memutar narasi secara otomatis berdasarkan posisi Anda.")
                            .font(.caption)
                            .frame(width: 313, alignment: .leading)
                    }
                }
                .padding(.bottom, 25)
                
                HStack (spacing: 12) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("AppText"))
                            .font(.body)
                            .frame(maxWidth: 50, maxHeight: 50)
                            .background(Color("AppGrey"))
                            .cornerRadius(86)
                    })
                    
                    Button(action: {
                        thirdOnboarding = true
                        ButtonHaptic()
                    }, label: {
                        HStack {
                            Text("Next (2/3)")
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(.black)
                        .cornerRadius(86)
                    })
                }
                .padding(.horizontal, 24)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 480)
            .background(.white)
            .cornerRadius(36)
            .shadow(radius: 5)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    OnboardingSecondView(secondOnboarding: .constant(false))
}
