//
//  PlayerView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 18/10/24.
//

import SwiftUI

struct PlayerView: View {
    
    @State private var trackBar = 0.0
    @State private var isPlaying = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let title = "Deskripsi"
    
    var body: some View {
        Spacer()
        ZStack {
            VStack {
                VStack {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                    
                    ProgressView("", value: trackBar, total: 300)
                        .accentColor(Color("AppButton"))
                        .scaleEffect(x: 1, y: 1.5, anchor: .bottom)
                    
                    HStack {
                        Text("1:30").font(.subheadline)
                        Spacer()
                        Text("-1:00").font(.subheadline)
                    }
                    .foregroundColor(.gray)
                    
                    HStack (spacing: 16) {
                        Button(action:  {
                            
                        }, label:  {
                            Image(systemName: "backward")
                                .foregroundColor(.black)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action:  {
                            
                        }, label:  {
                            Image(systemName: "15.arrow.trianglehead.counterclockwise")
                                .foregroundColor(.black)
                        })
                        .frame(width: 50, height: 50)
                        
                        ZStack {
                            Circle()
                            
                            Button(action:  {
                                isPlaying.toggle()
                            }, label:  {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                            })
                        }
                        
                        Button(action:  {
                            
                        }, label:  {
                            Image(systemName: "15.arrow.trianglehead.clockwise")
                                .foregroundColor(.black)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action:  {
                            
                        }, label:  {
                            Image(systemName: "forward")
                                .foregroundColor(.black)
                        })
                        .frame(width: 50, height: 50)
                        
                    }
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .onReceive(timer) { _ in
            if trackBar < 300 {
                trackBar += 1
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: 174)
        .background(Color.white)
        .cornerRadius(36)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
    }
}

#Preview {
    PlayerView()
}
