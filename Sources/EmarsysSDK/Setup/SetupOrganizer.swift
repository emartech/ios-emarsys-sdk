//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct SetupOrganizer {
    
    let stateMachine: StateMachine
    let sdkContext: SdkContext
    
    func setup() async throws {
        try await stateMachine.activate()
        sdkContext.sdkState = .active
    }
    
}

enum SetupState: String {
    case applyRemoteConfig
    case registerClient
    case registerPushToken
    case linkContact
}
