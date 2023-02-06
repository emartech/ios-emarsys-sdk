//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeDeviceInfoCollector: DeviceInfoCollector, Faked {
    var instanceId: String = UUID().uuidString
    
    let collect = "collect"
    let deviceTypeFunc = "deviceType"
    let osVersionFunc = "osVersion"
    
    func collect() async -> DeviceInfo {
        return try! handleCall(\.collect)
    }
    
    func deviceType() -> String {
        return try! handleCall()
    }
    
    func osVersion() -> String {
        return try! handleCall()
    }
}
