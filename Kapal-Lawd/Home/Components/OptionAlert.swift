//
//  Alert.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 20/11/24.
//

import SwiftUI

struct OptionAlertView: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let option1: (text: String, action: () -> Void)
    let option2: (text: String, action: () -> Void)
    let option3: (text: String, action: () -> Void)

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isPresented ? 3 : 0)
            
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    Text(title)
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    Text(message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    Divider()

                    VStack(spacing: 0) {
                        Button(action: {
                            ButtonHaptic()
                            option1.action()
                            isPresented = false
                        }) {
                            Text(option1.text)
                                .font(.body)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color(UIColor.systemBackground))

                        Divider()
                        
                        Button(action: {
                            ButtonHaptic()
                            option2.action()
                            isPresented = false
                        }) {
                            Text(option2.text)
                                .font(.body)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color(UIColor.systemBackground))

                        Divider()
                        
                        Button(action: {
                            ButtonHaptic()
                            option3.action()
                            isPresented = false
                        }) {
                            Text(option3.text)
                                .font(.body)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color(UIColor.systemBackground))
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

extension View {
    func threeOptionAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        option1: (text: String, action: () -> Void),
        option2: (text: String, action: () -> Void),
        option3: (text: String, action: () -> Void)
    ) -> some View {
        self.modifier(
            OptionAlertView(
                isPresented: isPresented,
                title: title,
                message: message,
                option1: option1,
                option2: option2,
                option3: option3
            )
        )
    }
}
