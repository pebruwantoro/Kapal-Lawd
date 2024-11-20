//
//  Alert.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 20/11/24.
//

import SwiftUI

struct OptionAlert: ViewModifier {
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
                secondaryButton: .destructive(Text(option2.text), action: option2.action)
            )
        }
    }
}

extension View {
    func threeOptionAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        option1: (text: String, action:  () -> Void),
        option2: (text: String, action:  () -> Void)
    ) -> some View {
        self.modifier(OptionAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            option1: option1,
            option2: option2
        ))
    }
}

//struct ContentView: View {
//    @State private var showAlert = false
//
//    var body: some View {
//        Button("Show Alert") {
//            showAlert = true
//        }
//        .threeOptionAlert(
//            isPresented: $showAlert,
//            title: "Anda berada di luar area booth.",
//            message: "Mendekatlah ke booth untuk mendapatkan pengalaman mendengarkan yang lebih baik. Namun, Anda tetap dapat memilih untuk melanjutkan narasi.",
//            option1: (text: "Lanjut Mendengarkan", action: {
//                print("Option 1 Selected")
//            }),
//            option2: (text: "Pilih Booth Lain", action: {
//                print("Option 2 Selected")
//            })
//        )
//    }
//}
//
//#Preview {
//    ContentView()
//}
