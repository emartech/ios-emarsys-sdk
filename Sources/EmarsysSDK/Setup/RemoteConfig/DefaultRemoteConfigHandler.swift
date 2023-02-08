//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct DefaultRemoteConfigHandler: RemoteConfigHandler {
    let deviceInfoCollector: DeviceInfoCollector
    
    func handle() -> [String : String]? {
        [:]
    }
}
