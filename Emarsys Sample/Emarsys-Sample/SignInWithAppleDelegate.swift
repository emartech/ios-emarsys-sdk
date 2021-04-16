//
//  Copyright © 2021. Emarsys. All rights reserved.
//

import Foundation
import AuthenticationServices
import EmarsysSDK

class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate, ObservableObject {
    var loginData: LoginData
    
    init(loginData: LoginData) {
        self.loginData = loginData
    }
        
    func handleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        guard let token = credentials.identityToken, let tokenString = String(data: token, encoding: .utf8) else { return }
        let contactFieldValue = credentials.email ?? credentials.user
        
        Emarsys.setAuthenticatedContactWithIdToken(tokenString) { error in
            if error == nil {
                self.loginData.isLoggedIn = true
                self.loginData.contactFieldValue = contactFieldValue
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError: Error) {
        print(didCompleteWithError.localizedDescription)
    }
    
}
