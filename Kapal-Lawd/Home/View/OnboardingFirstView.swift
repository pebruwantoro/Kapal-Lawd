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
    
    var body: some View {
        if secondOnboarding {
            OnboardingSecondView(secondOnboarding: self.$secondOnboarding)
        } else {
            Spacer()
            NavigationStack {
                Image("imageone")
                    .resizable().scaledToFill()
                    .frame(width: 370, height: 210)
                    .clipShape(HalfRoundedRectangle(cornerRadius: 36))
                    .offset(y: -38)
                
                VStack {
                    Text("Gunakan Earphone")
                        .font(.title).bold()
                        .frame(width: 313, alignment: .leading)
                    
                    VStack (spacing: 16) {
                        Text("Hubungkan earphone Anda sekarang.")
                            .italic()
                            .font(.subheadline)
                            .frame(width: 313, alignment: .leading)
                        
                        
                        Text("Pengalaman Audium akan maksimal dengan earphone pribadi untuk mendapatkan narasi dari setiap booth.")
                            .font(.caption)
                            .frame(width: 313, alignment: .leading)
                    }
                }
                .padding(.bottom, 25)
                
                HStack (spacing: 12) {
                    Button(action: {
                        startOnboarding = true
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
    OnboardingFirstView(startOnboarding: .constant(false))
}
