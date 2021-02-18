//
//  GoogleDelegate.swift
//  Emarsys-Sample
//

import Foundation
import GoogleSignIn
import EmarsysSDK

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    @Published var signedIn: Bool = false
    @Published var idToken: String = ""
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            signedIn = false
            
            return
        }
        idToken = user.authentication.idToken
        signedIn = true
        
        guard let userId = user.userID else { return }
        
        Emarsys.setAuthorizedContactWithContactFieldValue(userId, idToken: idToken, completionBlock: nil)
    }
}

