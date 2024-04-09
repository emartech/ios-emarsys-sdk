//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeRemoteConfigClient: RemoteConfigClient, Mimic {
        
    let fnFetchRemoteConfig = Fn<RemoteConfigResponse?>()
    
    func fetchRemoteConfig() async throws -> RemoteConfigResponse? {
        return try fnFetchRemoteConfig.invoke()
    }
}
