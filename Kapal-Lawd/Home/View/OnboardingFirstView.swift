//
//  OnboardingFirstView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 12/11/24.
//

import SwiftUI

struct OnboardingFirstView: View {
    
    @Binding var startOnboarding: Bool
    @State private var secondOnboarding = false
    @State private var isBack = false
    
    var body: some View {
        if secondOnboarding {
            OnboardingSecondView(secondOnboarding: self.$secondOnboarding)
        } else if isBack {
            
        } else {
            VStack {
                Spacer()
                NavigationStack {
                    ZStack {
                        Color("AppWhite")
                        VStack {
                            Image("imageone")
                                .resizable().scaledToFill()
                                .frame(width: 370, height: 210)
                                .clipShape(HalfRoundedRectangle(cornerRadius: 36))
                                .offset(y: -16)
                            
                            VStack {
                                VStack {
                                    Text("Gunakan Earphone")
                                        .font(.title).bold()
                                        .frame(width: 313, alignment: .leading)
                                    
                                    
                                    Text("Hubungkan earphone Anda sekarang.")
                                        .italic()
                                        .font(.subheadline)
                                        .frame(width: 313, alignment: .leading)
                                }
                                .frame(width: 313, height: 50)
                                .padding(.bottom, 12)
                                
                                Text("Pengalaman Audium akan maksimal jika menggunakan earphone pribadi untuk mendapatkan narasi dari setiap booth.")
                                    .font(.caption)
                                    .frame(width: 313, height: 50, alignment: .leading)
                                
                            }
                            .frame(width: 313, height: 144)
                            .foregroundColor(Color("AppText"))
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
                                    secondOnboarding = true
                                    ButtonHaptic()
                                }, label: {
                                    HStack {
                                        Text("Next (1/3)")
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(Color("ButtonText"))
                                    .font(.body)
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color("AppButton"))
                                    .cornerRadius(86)
                                })
                            }
                            .padding(.horizontal, 24)
                            
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 480)
                .cornerRadius(36)
                .shadow(radius: 5)
                .padding(.horizontal, 16)
            }
            .background {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
        }
    }
}

#Preview {
    OnboardingFirstView(startOnboarding: .constant(false))
}
