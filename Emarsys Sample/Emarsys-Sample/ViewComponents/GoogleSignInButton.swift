//
//  GoogleSignInButton.swift
//  Emarsys-Sample
//

import GoogleSignIn
import SwiftUI

struct GoogleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.colorScheme = .light
        button.style = .wide
        return button
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
