//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol DeviceInfoCollector {
    
    func collect() async -> DeviceInfo
    func deviceType() async -> String
    func osVersion() async -> String
}
