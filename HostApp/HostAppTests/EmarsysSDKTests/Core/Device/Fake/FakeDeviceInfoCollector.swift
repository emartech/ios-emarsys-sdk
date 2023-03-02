
import Foundation
@testable import EmarsysSDK

@SdkActor
struct FakeDeviceInfoCollector: DeviceInfoCollector, Faked {
    
    var faker = Faker()
    
    let collect: String = "collect"
    let deviceTypeKey: String = "deviceType"
    let osVersionKey: String = "osVersion"
    let hardwareIdKey: String = "hardwareId"
    
    func collect() async -> DeviceInfo {
        return try! handleCall(\.collect)
    }
    
    func deviceType() -> String {
        return try! handleCall(\.deviceTypeKey)
    }
    
    func osVersion() -> String {
        return try! handleCall(\.osVersionKey)
    }
    
    func hardwareId() -> String {
        return try! handleCall(\.hardwareIdKey)
    }
}
