//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct DefaultDeviceInfoCollector: DeviceInfoCollector {
    
    func collect() async -> DeviceInfo {
        return "" as! DeviceInfo
    }
    
    func deviceType() -> String {
        return ""
    }
    
    func osVersion() -> String {
        return ""
    }
    
}
