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
    @State private var isBack = false
    
    var body: some View {
        if thirdOnboarding {
            OnboardingThirdView(thirdOnboarding: self.$thirdOnboarding)
        } else if isBack {
            OnboardingFirstView(startOnboarding: $isBack)
        } else {
            Spacer()
            NavigationStack {
                ZStack {
                    Color("AppWhite")
                    VStack {
                        Image("imagetwo")
                            .resizable().scaledToFill()
                            .frame(width: 370, height: 210)
                            .clipShape(HalfRoundedRectangle(cornerRadius: 36))
                            .offset(y: -16)
                        
                        VStack {
                            VStack {
                                Text("Bluetooth dan Lokasi")
                                    .font(.title).bold()
                                    .frame(width: 313, alignment: .leading)
                                
                                Text("Nyalakan bluetooth dan izinkan akses lokasi.")
                                    .italic()
                                    .font(.subheadline)
                                    .frame(width: 313, alignment: .leading)
                            }
                            .frame(width: 313, height: 50)
                            .padding(.bottom, 12)
                                
                                Text("Audium menggunakan Bluetooth dan layanan lokasi untuk mendeteksi lokasi untuk memutar narasi secara otomatis berdasarkan posisi Anda.")
                                    .font(.caption)
                                    .frame(width: 313, height: 50, alignment: .leading)
                            
                        }
                        .frame(width: 313, height: 144)
                        .padding(.bottom, 30)
                        
                        HStack (spacing: 12) {
                            Button(action: {
                                isBack = true
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
                                .foregroundColor(Color("ButtonText"))
                                .font(.body)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color("AppButton"))
                                .cornerRadius(86)
                            })
                        }
//                        .padding(.top, 10)
                        .padding(.horizontal, 24)
                    }
                }
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
