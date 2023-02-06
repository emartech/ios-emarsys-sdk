//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RegisterClientState: State {
    
    var deviceClient: DeviceClient
    
    var name = SetupState.registerClient.rawValue
    
    var nextStateName: String? = SetupState.registerPushToken.rawValue
    
    func prepare() {
    }

    func active() async throws {
        try await deviceClient.registerClient()
    }
    
    func relax() {
    }
    
}
