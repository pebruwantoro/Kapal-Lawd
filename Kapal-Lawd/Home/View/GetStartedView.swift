//
//  GetStartedView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 12/11/24.
//

import SwiftUI

struct GetStartedView: View {
    
    @State private var startOnboarding = false
    
    var body: some View {     
        if startOnboarding {
            OnboardingFirstView(startOnboarding: self.$startOnboarding)
        } else {
            VStack {
                Spacer()
                NavigationStack {
                    ZStack {
                        Color("AppWhite")
                        VStack {
                            Image("header")
                                .resizable().scaledToFill()
                                .frame(width: 370, height: 210)
                                .clipShape(HalfRoundedRectangle(cornerRadius: 36))
                                .offset(y: -30)
                            
                            VStack {
                                Text("Mulai Audium")
                                    .font(.title).bold()
                                    .frame(width: 313, alignment: .leading)
                                
                                VStack (spacing: 16) {
                                    Text("Menyiapkan pengalaman yang tak terlupakan untuk Anda.")
                                        .italic()
                                        .font(.subheadline)
                                        .frame(width: 313, alignment: .leading)
                                    
                                    
                                    Text("Ikuti langkah-langkah ini untuk merasakan pengalaman baru dalam mengunjungi pameran.")
                                        .italic()
                                        .font(.subheadline)
                                        .frame(width: 313, alignment: .leading)
                                }
                            }
                            .foregroundColor(Color("AppText"))
                            .padding(.bottom, 25)
                            
                            VStack {
                                Button(action: {
                                    startOnboarding = true
                                    ButtonHaptic()
                                    
                                }, label: {
                                    Text("Start with Audium")
                                        .foregroundColor(.white)
                                        .font(.body)
                                        .frame(maxWidth: .infinity, maxHeight: 50)
                                        .background(.black)
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

struct HalfRoundedRectangle: Shape {
    var cornerRadius: CGFloat = 20.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        path.move(to: bottomLeft)
        
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y),
                          control: topLeft)
        
        path.addLine(to: CGPoint(x: topRight.x - cornerRadius, y: topRight.y))
        path.addQuadCurve(to: CGPoint(x: topRight.x, y: topRight.y + cornerRadius),
                          control: topRight)
        
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        
        return path
    }
}

#Preview {
    GetStartedView()
}
