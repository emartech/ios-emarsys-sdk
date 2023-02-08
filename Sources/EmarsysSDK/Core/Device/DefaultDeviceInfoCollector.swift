//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
import UserNotifications
import UIKit
import Combine

@SdkActor
struct DefaultDeviceInfoCollector: DeviceInfoCollector {
    let notificationCenterWrapper: NotificationCenterWrapper
    let secureStorage: SecureStorage
    let uuidProvider: any StringProvider
    let logger: SdkLogger
    
    let hardwareIdKey = "kHardwareIdKey"
    let platform: String = "iOS"
    let sdkVersion: String = ""
    var _hardwareId: String?
    
    var timeZone: String {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.dateFormat = "xxxx"
        return formatter.string(from: Date())
    }
    
    let languageCode: String = NSLocale.preferredLanguages[0]
    
    let applicationVersion: String =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
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
    
    @MainActor var systemName: String {
        UIDevice().systemName
    }
    
    func deviceType() async -> String {
        await MainActor.run(body: {
            UIDevice().model
        })
    }
    
    func osVersion() async -> String {
        await MainActor.run(body: {
            UIDevice().systemVersion
        })
        
    }
    
    var hardwareId: String {
        mutating get async {
            if (_hardwareId == nil) {
                _hardwareId = loadHardwareId()
                
                if (_hardwareId == nil) {
                    _hardwareId = await generateHardwareId()
                    saveHardwareId(id: _hardwareId!)
                }
            }
            return _hardwareId!
        }
    }
    
    func collect() async -> DeviceInfo {
        return await DeviceInfo(platform: platform,
                                applicationVersion: applicationVersion,
                                deviceModel: deviceModel,
                                osVersion: osVersion(),
                                sdkVersion: sdkVersion,
                                language: languageCode,
                                timezone: timeZone,
                                pushSettings: await getPushSettings()
        )
    }
    
    func getPushSettings() async -> PushSettings {
        
        let settings = await notificationCenterWrapper.notificationSettings()
        
        return PushSettings(authorizationStatus: settings.authorizationStatus.asString(),
                            soundSetting: settings.soundSetting.asString(),
                            badgeSetting: settings.badgeSetting.asString(),
                            alertSetting: settings.alertSetting.asString(),
                            notificationCenterSetting: settings.notificationCenterSetting.asString(),
                            lockScreenSetting: settings.lockScreenSetting.asString(),
                            carPlaySetting: settings.carPlaySetting.asString(),
                            alertStyle: settings.alertStyle.asString(),
                            showPreviewsSetting: settings.showPreviewsSetting.asString(),
                            criticalAlertSetting: settings.criticalAlertSetting.asString(),
                            providesAppNotificationSettings: settings.providesAppNotificationSettings.description,
                            scheduledDeliverySetting: settings.scheduledDeliverySetting.asString(),
                            timeSensitiveSetting: settings.timeSensitiveSetting.asString()
        )
    }
    
    private func generateHardwareId() async -> String {
        await uuidProvider.provide()
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
            let logEntry = LogEntry(topic: "DeviceInfoCollector", data: ["message":"hardwareId save to storage failed"])
            logger.log(logEntry: logEntry, level: .error)
        }
    }
}
