//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct SetupOrganizer {
    
    let stateMachine: StateMachine
    
    
}

enum SetupState: String {
    case fetchRemoteConfig
    case registerClient
    case registerPushToken
    case setContact
}
