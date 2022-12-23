//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RegisterClientState: State {
    
    var context: StateContext?
    
    let emarsysClient: EmarsysClient
    
    var name = SetupState.registerClient.rawValue
    
    func prepare() {
    }

    func activate() async throws {
        await emarsysClient.registerClient()
        try! await self.context?.switchTo(stateName: SetupState.registerPushToken.rawValue)
    }
    
    func relax() {
    }
    
}
