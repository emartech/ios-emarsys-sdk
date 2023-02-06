//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol DeviceInfoCollector {
    
    func collect() async -> DeviceInfo
    func deviceType() -> String
    func osVersion() -> String
}
