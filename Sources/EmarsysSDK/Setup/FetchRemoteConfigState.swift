//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct FetchRemoteConfigState: State {
    
    var context: StateContext?
    
    let remoteConfigClient: RemoteConfigClient
        
    var name = SetupState.fetchRemoteConfig.rawValue
    
    func prepare() {
    }
    
    func activate() async throws {
        try await remoteConfigClient.applyActiveConfig()
        try await context?.switchTo(stateName: SetupState.registerClient.rawValue)
    }
    
    func relax() {
    }
    
}
