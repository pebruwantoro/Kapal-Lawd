//
//  SelectLocationView.swift
//  Kapal-Lawd
//
//  Created by Elsavira T on 18/11/24.
//

import SwiftUI

struct SelectLocationView: View {
    
    @State private var isVisible = false
    let boothName = ["Audium", "Polaread"]
    let boothNumber = ["IE.4", "SI.6"]
    let boothCategory = ["Pengalaman Pengguna", "Social Impact"]
    let boothDistance = ["1", "1,2"]
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                
                Text("2 booth terdekat")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .padding(.bottom, 2)
                    .foregroundColor(.gray)
                
                ForEach(0..<boothName.count, id: \.self) { index in
                    Button(action: {
                        
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Image("AppLogo")
                                    .resizable()
                                    .frame(width: 74, height: 74)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(boothNumber[index])
                                        .font(.footnote)
                                        .padding(.horizontal, 6)
                                    
                                    Text(boothName[index])
                                        .font(.headline)
                                        .padding(.horizontal, 6)
                                    
                                    Text(boothCategory[index])
                                        .font(.caption).italic()
                                        .padding(.horizontal, 6)
                                }
                                .frame(width: 180, height: 54, alignment: .leading)
                                
                                HStack (spacing: 1) {
                                    Spacer()
                                    Text("\(boothDistance[index]) m")
                                        .font(.footnote)
                                        .frame(width: 38)
                                    Image(systemName: "chevron.forward")
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                            }
                            
                            Text("Audium mengubah pengalaman Anda di berbagai ruang dengan menyediakan panduan audio tanpa sentuhan yang didukung oleh teknologi AudiTag.")
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 4)
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 155)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    }
                }
                Spacer().frame(height: 10)
            }
            .frame(maxWidth: .infinity, maxHeight: 431)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(36)
            .shadow(radius: 5)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 150)
            .onAppear {
                withAnimation(.easeIn(duration: 0.4)) {
                    isVisible = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SelectLocationView()
}
