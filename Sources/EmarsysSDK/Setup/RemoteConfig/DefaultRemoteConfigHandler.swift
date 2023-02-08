//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct DeafultRemoteConfigHandler: RemoteConfigHandler {
    let deviceInfo: DeviceInfoCollector
    
    func handle() -> [String : String]? {
        [:]
    }
}
