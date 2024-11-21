//
//  OnboardingThirdView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 14/11/24.
//

import SwiftUI

struct OnboardingThirdView: View {
    
    @Binding var thirdOnboarding: Bool
    @State private var finalOnboarding = false
    @State private var isBack = false
    
    var body: some View {
        if finalOnboarding {
            OnboardingFinalView(finalOnboarding: self.$finalOnboarding)
        } else if isBack {
            OnboardingSecondView(secondOnboarding: $isBack)
        }else {
            Spacer()
            NavigationStack {
                ZStack {
                    Color("AppWhite")
                    VStack {
                        Image("imagethree")
                            .resizable().scaledToFill()
                            .frame(width: 370, height: 210)
                            .clipShape(HalfRoundedRectangle(cornerRadius: 36))
                            .offset(y: -16)
                        
                        VStack {
                            VStack {
                                Text("Booth dengan AudiTag™")
                                    .font(.title).bold()
                                    .frame(width: 318, alignment: .leading)
                                
                                Text("Kunjungi booth dengan tanda Tersedia di Audium")
                                    .italic()
                                    .font(.subheadline)
                                    .frame(width: 313, alignment: .leading)
                            }
                            .frame(width: 313, height: 78)
                            .padding(.top, 6)
                            
                            
                            Text("Dekati booth yang dilengkapi dengan AudiTag™, dan Audium akan memutar narasi saat Anda mendekat. Otomatis!")
                                .font(.caption)
                                .frame(width: 313, height: 50, alignment: .leading)
                            
                        }
                        .foregroundColor(Color("AppText"))
                        .padding(.bottom, 34)
                        
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
                                finalOnboarding = true
                                ButtonHaptic()
                            }, label: {
                                HStack {
                                    Text("Next (3/3)")
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
            .background(.white)
            .cornerRadius(36)
            .shadow(radius: 5)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    OnboardingThirdView(thirdOnboarding: .constant(false))
}
