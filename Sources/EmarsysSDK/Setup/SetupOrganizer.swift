//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct SetupOrganizer {
    
    let stateMachine: StateMachine
    let sdkContext: SdkContext
    
    func setup() async throws { // TODO: handle errors
        try await stateMachine.activate()
        stateMachine.$stateLifecycle.sink { stateLifecycle in
            if stateLifecycle!.name == SetupState.linkContact.rawValue && stateLifecycle!.lifecycle == .relaxed {
                sdkContext.sdkState = .active
            }
        }
    }
    
}

enum SetupState: String {
    case fetchRemoteConfig
    case registerClient
    case registerPushToken
    case linkContact
}
