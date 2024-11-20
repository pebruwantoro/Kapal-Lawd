//
//  Alert.swift
//  Kapal-Lawd
//
//  Created by Syafrie Bachtiar on 20/11/24.
//

import SwiftUI

struct AlertSheet: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let option1: (text: String, action: () -> Void)
    let option2: (text: String, action: () -> Void)
    let option3: (text: String, action: () -> Void)

    func body(content: Content) -> some View {
        content.actionSheet(isPresented: $isPresented) {
            ActionSheet(
                title: Text(title),
                message: Text(message),
                buttons: [
                    .default(Text(option1.text), action: option1.action),
                    .cancel(Text(option2.text), action: option2.action),
                    .destructive(Text(option3.text), action: option3.action),
                ]
            )
        }
    }
}

extension View {
    func threeOptionActionSheet(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        //action : @escaping ->
        //Escaping in Action
//    However, when a closure is used in an asynchronous operation or stored for later use, it becomes @escaping. This means the closure can be called after the function it was passed to has returned. //https://medium.com/@fun_volt_ox_253/what-is-escaping-in-swift-2ba1c5da86be
        
        option1: (text: String, action: () -> Void),
        option2: (text: String, action: () -> Void),
        option3: (text: String, action: () -> Void)
    ) -> some View {
        self.modifier(AlertSheet(
            isPresented: isPresented,
            title: title,
            message: message,
            option1: option1,
            option2: option2,
            option3: option3
        ))
    }
}

//Panggil di Content View
//struct ContentView: View {
//@State private var showActionSheet = false
//
//var body: some View {
//    Button("Show Action Sheet") {
//        showActionSheet = true
//    }
//    .threeOptionActionSheet(
//        isPresented: $showActionSheet,
//        title: "Choose an Option",
//        message: "Please select one of the following actions:",
//        option1: (text: "Option 1", action: {
//            print("Option 1 Selected")
//        }),
//        option2: (text: "Option 2", action: {
//            print("Option 2 Selected")
//        }),
//        option3: (text: "Option 3", action: {
//            print("Option 3 Selected")
//        })
//    )
//}
//}

