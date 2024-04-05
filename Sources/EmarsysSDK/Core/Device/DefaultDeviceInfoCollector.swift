//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
import UserNotifications
import Combine
import Darwin

@SdkActor
class DefaultDeviceInfoCollector: DeviceInfoCollector {
    private let notificationCenterWrapper: UserNotificationCenterWrapper
    private let secureStorage: SecureStorage
    private let uuidProvider: any StringProvider
    private let sdkConfig: SdkConfig
    private let logger: SdkLogger
    
    private let hardwareIdKey = "kHardwareIdKey"
    private let platform: String = "ios"
    
    init(notificationCenterWrapper: UserNotificationCenterWrapper,
         secureStorage: SecureStorage,
         uuidProvider: any StringProvider,
         sdkConfig: SdkConfig,
         logger: SdkLogger) {
        self.notificationCenterWrapper = notificationCenterWrapper
        self.secureStorage = secureStorage
        self.uuidProvider = uuidProvider
        self.sdkConfig = sdkConfig
        self.logger = logger
    }
    
    var timeZone: String {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.dateFormat = "xxxx"
        return formatter.string(from: Date())
    }
    
    let applicationVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let model = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in
                String(validatingUTF8: ptr)
            }
        }
        
        return (model != nil) ? model! : "unknown model"
    }
    
    var systemName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.sysname) {
            $0.withMemoryRebound(to: CChar.self, capacity:  1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown Identifier"
    }
    
    func collect() async -> DeviceInfo {
        return DeviceInfo(platform: platform,
                          applicationVersion: applicationVersion,
                          deviceModel: deviceModel,
                          osVersion: await osVersion(),
                          sdkVersion: sdkConfig.version,
                          language: languageCode(),
                          timezone: timeZone,
                          pushSettings: await pushSettings(),
                          hardwareId: hardwareId()
        )
    }
    
    func osVersion() async -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.version) {
            $0.withMemoryRebound(to: CChar.self, capacity:  1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown Identifier"
    }
    
    func deviceType() async -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity:  1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown Identifier"
    }
    
    func hardwareId() -> String {
        var hardwareId: String
        if let storedHardwareId = loadHardwareId() {
            hardwareId = storedHardwareId
        } else {
            hardwareId = uuidProvider.provide()
            saveHardwareId(id: hardwareId)
        }
        
        return hardwareId
    }
    
    func pushSettings() async -> PushSettings {
        return await notificationCenterWrapper.notificationSettings()
    }
    
    func languageCode() -> String {
        NSLocale.preferredLanguages[0]
    }
    
    private func loadHardwareId() -> String? {
        var result: String? = nil
        do {
            result = try secureStorage.get(key: hardwareIdKey, accessGroup: nil)
        } catch {
        }
        return result
    }
    
    private func saveHardwareId(id: String) {
        do {
            try secureStorage.put(item: id, key: hardwareIdKey, accessGroup: nil)
        } catch {
            let logEntry = LogEntry(topic: "DeviceInfoCollector", data: ["message": "hardwareId save to storage failed"])
            logger.log(logEntry: logEntry, level: .error)
        }
    }
}
