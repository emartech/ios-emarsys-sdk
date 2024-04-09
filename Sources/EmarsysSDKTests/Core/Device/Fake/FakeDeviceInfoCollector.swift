
import Foundation
@testable import EmarsysSDK
import mimic

@SdkActor
struct FakeDeviceInfoCollector: DeviceInfoCollector, Mimic {
    let fnCollect = Fn<DeviceInfo>()
    let fnDeviceType = Fn<String>()
    let fnOsVersion = Fn<String>()
    let fnHardwareId = Fn<String>()
    let fnPushSettings = Fn<PushSettings>()
    let fnLanguageCode = Fn<String>()
    
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
    
    func pushSettings() async -> PushSettings {
        return try! fnPushSettings.invoke()
    }
    
    func languageCode() -> String {
        return try! fnLanguageCode.invoke()
    }
}
