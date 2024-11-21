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

    func body(content: Content) -> some View {
        content.alert(isPresented: $isPresented) {
            Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .default(Text(option1.text), action: option1.action),
                secondaryButton: .default(Text(option2.text), action: option2.action)
            )
        }
    }
}

extension View {
    func threeOptionAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        option1: (text: String, action: () -> Void),
        option2: (text: String, action: () -> Void)
    ) -> some View {
        self.modifier(
            OptionAlertView(
                isPresented: isPresented,
                title: title,
                message: message,
                option1: option1,
                option2: option2
            )
        )
    }
}
