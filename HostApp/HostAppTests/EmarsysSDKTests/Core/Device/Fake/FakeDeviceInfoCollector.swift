
import Foundation
@testable import EmarsysSDK
import mimic

@SdkActor
struct FakeDeviceInfoCollector: DeviceInfoCollector, Mimic {
    
    let fnCollect = Fn<DeviceInfo>()
    let fnDeviceType = Fn<String>()
    let fnOsVersion = Fn<String>()
    let fnHardwareId = Fn<String>()
    
    func collect() async -> DeviceInfo {
        return try! fnCollect.invoke()
    }
    
    func deviceType() -> String {
        return try! fnDeviceType.invoke()
    }
    
    func osVersion() -> String {
        return try! fnOsVersion.invoke()
    }
    
    func hardwareId() -> String {
        return try! fnHardwareId.invoke()
    }
}
