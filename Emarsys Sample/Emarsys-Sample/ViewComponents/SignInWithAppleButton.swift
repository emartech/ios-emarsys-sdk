//
//  Copyright © 2021. Emarsys. All rights reserved.
//

import SwiftUI
import AuthenticationServices

 struct SignInWithAppleButton: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton()
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}
