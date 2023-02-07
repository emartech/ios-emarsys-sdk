
import Foundation
@testable import EmarsysSDK

@SdkActor
struct FakeDeviceInfoCollector: DeviceInfoCollector, Faked {
    
    let instanceId = UUID().uuidString
    
    let collect: String = "collect"
    
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
