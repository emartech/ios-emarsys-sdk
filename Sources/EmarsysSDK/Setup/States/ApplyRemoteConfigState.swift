//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct ApplyRemoteConfigState: State {

    let remoteConfigHandler: RemoteConfigHandler

    var name = SetupState.applyRemoteConfig.rawValue

    var nextStateName: String? = SetupState.registerClient.rawValue

    func prepare() {
    }

    func active() async throws {
        try await remoteConfigHandler.handle()
    }

    func relax() {
    }

}
