//
//  OnboardingFinalView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 14/11/24.
//

import SwiftUI

struct OnboardingFinalView: View {
    
    @Binding var finalOnboarding: Bool
    @State private var spotHomepage = false
    
    var body: some View {
        if spotHomepage {
            SpotHomepageView(spotHomepage: self.$spotHomepage)
        } else {
            Spacer()
            NavigationStack {
                Image("imageone")
                    .resizable().scaledToFill()
                    .frame(width: 370, height: 210)
                    .clipShape(HalfRoundedRectangle(cornerRadius: 36))
                    .offset(y: -38)
                
                VStack {
                    Text("Mulai Perjalanan Anda!")
                        .font(.title).bold()
                        .frame(width: 318, alignment: .leading)
                    
                    VStack (spacing: 16) {
                        Text("Rasakan pengalaman baru dalam menikmati pameran.")
                            .italic()
                            .font(.subheadline)
                            .frame(width: 313, alignment: .leading)
                        
                        
                        Text("Jelajahi pameran dengan bebas, dan Audium akan menangani sisanya, memberikan pengalaman yang mulus dan kaya di setiap langkah.")
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
                        spotHomepage = true
                        ButtonHaptic()
                    }, label: {
                        HStack {
                            Text("Mulai Eksplorasi")
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
    OnboardingFinalView(finalOnboarding: .constant(false))
}
