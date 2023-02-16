//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
class RegisterPushTokenState: State {
    
    let pushClient: PushClient
    var secureStorage: SecureStorage
    
    init(pushClient: PushClient, secureStorage: SecureStorage) {
        self.pushClient = pushClient
        self.secureStorage = secureStorage
    }
    
    var name = SetupState.registerPushToken.rawValue
    
    func prepare() {
    }
    
    func active() async throws {
        guard let pushToken: String = secureStorage[Constants.Push.pushToken.rawValue] else {
            return
        }
        let lastSentPushToken: String? = secureStorage[Constants.Push.lastSentPushToken.rawValue]
        
        if lastSentPushToken == nil || pushToken != lastSentPushToken {
            try await pushClient.registerPushToken(pushToken)
            secureStorage[Constants.Push.lastSentPushToken.rawValue] = pushToken
        }
    }
    
    func relax() {
    }
    
}
