//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RegisterPushTokenState: State {
        
    let pushClient: PushClient
    
    var name = SetupState.registerPushToken.rawValue
    
    var nextStateName: String? = SetupState.linkContact.rawValue
    
    func prepare() {
    }
    
    func active() async throws {
        // try await pushClient.registerPushToken("")
    }
    
    func relax() {
    }
    
}
