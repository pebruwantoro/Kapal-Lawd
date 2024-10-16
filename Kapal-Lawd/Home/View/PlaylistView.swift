//
//  PlaylistView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 16/10/24.
//

import SwiftUI

struct PlaylistView: View {
    
    @Binding var isExploring: Bool
    
    var body: some View {
        NavigationStack {
            if isExploring {
                FindAuditagView(isExploring: $isExploring)
            } else {
                VStack {
                    HStack {
                        Button(action:  {
                            isExploring = true
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .frame(maxWidth: 28, maxHeight: 28)
                                .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                                .cornerRadius(86)
                        })
                        
                        Text("AudiTag Collections")
                            .frame(maxWidth: 283)
                            .font(.headline)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .padding(.trailing, 50)
                    
                    HStack (spacing: 16) {
                        Image("witjk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack (alignment: .leading) {
                            Text("WITJK ON HUNDRED #6 - #8")
                                .fontWeight(.semibold)
                            
                            Text("By Arief Witjaksana")
                                .font(.footnote)
                            
                            Text("October 18, 2024")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                        .padding(.trailing, 36)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    
                    VStack {
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed metus orci, sagittis et dolor at, dignissim lobortis sapien. Proin id orci eget purus convallis maximus eu in eros. Fusce vestibulum fermentum justo ut iaculis. Suspendisse venenatis blandit diam, in porttitor lacus faucibus sit amet. ")
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 108)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    
                    VStack (spacing: 16) {
                        VStack (alignment: .leading) {
                            Text("TRACKLIST")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 25, alignment: .topLeading)
                        
                        
                        HStack {
                            VStack (alignment: .leading) {
                                Text("Deskripsi")
                                    .bold()
                                Text("2:30")
                            }
                            Spacer()
                            Image("sound")
                            
                        }.frame(maxWidth: .infinity, maxHeight: 60)
                        
                        HStack {
                            VStack (alignment: .leading) {
                                Text("Deskripsi")
                                    .bold()
                                Text("2:30")
                            }
                            Spacer()
                            Image("playbutton")
                            
                        }.frame(maxWidth: .infinity, maxHeight: 60)
                        
                        HStack {
                            VStack (alignment: .leading) {
                                Text("Deskripsi")
                                    .bold()
                                Text("2:30")
                            }
                            Spacer()
                            Image("playbutton")
                            
                        }.frame(maxWidth: .infinity, maxHeight: 60)
                        
                        HStack {
                            VStack (alignment: .leading) {
                                Text("Deskripsi")
                                    .bold()
                                Text("2:30")
                            }
                            Spacer()
                            Image("playbutton")
                            
                        }.frame(maxWidth: .infinity, maxHeight: 60)
                    }.padding(.bottom, 16)
                    
                    VStack {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 174)
                    .background(Color.white)
                    .cornerRadius(36)
                    .shadow(radius: 5)
                    
                }
                .padding(.horizontal, 16)
            }
        }
    }
}



#Preview {
    PlaylistView(isExploring: .constant(false))
}
