//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RegisterClientState: State {
    
    let emarsysClient: EmarsysClient
    
    var name = SetupState.registerClient.rawValue
    
    var nextStateName: String? = SetupState.registerPushToken.rawValue
    
    func prepare() {
    }

    func active() async throws {
        await emarsysClient.registerClient()
    }
    
    func relax() {
    }
    
}
