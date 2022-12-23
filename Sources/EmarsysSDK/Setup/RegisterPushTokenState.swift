//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RegisterPushTokenState: State {
    
    var context: StateContext?
    
    let pushClient: PushClient
    
    var name = SetupState.registerPushToken.rawValue
    
    func prepare() {
    }
    
    func activate() async throws {
        try await pushClient.registerPushToken()
        try! await self.context?.switchTo(stateName: SetupState.setContact.rawValue)
    }
    
    func relax() {
    }
    
}
