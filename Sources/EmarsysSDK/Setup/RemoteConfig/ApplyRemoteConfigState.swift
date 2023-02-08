//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct ApplyRemoteConfigState: State {

    let remoteConfigClient: RemoteConfigClient
    let defaultRemoteConfigHandler: RemoteConfigHandler
        
    var name = SetupState.applyRemoteConfig.rawValue
    
    var nextStateName: String? = SetupState.registerClient.rawValue
    
    func prepare() {
    }
    
    func active() async throws {
       // try await remoteConfigClient.applyActiveConfig()
    }
    
    func relax() {
    }
    
}
