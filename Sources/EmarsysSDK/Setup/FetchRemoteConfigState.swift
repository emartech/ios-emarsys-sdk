//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct FetchRemoteConfigState: State {

    let remoteConfigClient: RemoteConfigClient
        
    var name = SetupState.fetchRemoteConfig.rawValue
    
    var nextStateName: String? = SetupState.registerClient.rawValue
    
    func prepare() {
    }
    
    func active() async throws {
        try await remoteConfigClient.applyActiveConfig()
    }
    
    func relax() {
    }
    
}
