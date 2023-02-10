//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK

struct FakeRemoteConfigClient: RemoteConfigClient, Faked {
    
    var faker = Faker()
    
    let fetchRemoteConfig = "fetchRemoteConfig"
    
    func fetchRemoteConfig() async throws -> RemoteConfigResponse? {
        return try! handleCall(\.fetchRemoteConfig)
    }
}
