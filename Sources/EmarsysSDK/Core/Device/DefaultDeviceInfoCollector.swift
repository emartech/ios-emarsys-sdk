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
    let uuidProvider: any UuidProvider
    let logger: SDKLogger
    
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
        
        return PushSettings(authorizationStatus: authorisationStatusToString(status: settings.authorizationStatus),
                            soundSetting: settingToString(setting: settings.soundSetting),
                            badgeSetting: settingToString(setting: settings.badgeSetting),
                            alertSetting: settingToString(setting: settings.alertSetting),
                            notificationCenterSetting: settingToString(setting: settings.notificationCenterSetting),
                            lockScreenSetting: settingToString(setting: settings.lockScreenSetting),
                            carPlaySetting: settingToString(setting: settings.carPlaySetting),
                            alertStyle: alertStyleSettingToString(setting: settings.alertStyle),
                            showPreviewsSetting: showPreviewSettingToString(setting: settings.showPreviewsSetting),
                            criticalAlertSetting: settingToString(setting: settings.criticalAlertSetting),
                            providesAppNotificationSettings: settings.providesAppNotificationSettings.description,
                            scheduledDeliverySetting: settingToString(setting: settings.scheduledDeliverySetting),
                            timeSensitiveSetting: settingToString(setting: settings.timeSensitiveSetting)
        )
    }
    
    private func settingToString(setting: UNNotificationSetting) -> String {
        var result = "notSupported"
        
        switch (setting) {
        case UNNotificationSetting.enabled:
            result = "enabled"
        case UNNotificationSetting.disabled:
            result = "disabled"
        case UNNotificationSetting.notSupported:
            result = "notSupported"
        default: result = "notSupported"
        }
        
        return result
    }
    
    private func showPreviewSettingToString(setting: UNShowPreviewsSetting) -> String {
        var result = "never"
        
        switch (setting) {
        case UNShowPreviewsSetting.never:
            result = "never"
        case UNShowPreviewsSetting.whenAuthenticated:
            result = "whenAuthenticated"
        case UNShowPreviewsSetting.always:
            result = "always"
        default: result = "never"
        }
        
        return result
    }
    
    private func alertStyleSettingToString(setting: UNAlertStyle) -> String {
        var alertStyle = "none"
        
        switch (setting) {
        case UNAlertStyle.alert:
            alertStyle = "alert"
        case UNAlertStyle.banner:
            alertStyle = "banner"
        case UNAlertStyle.none:
            alertStyle = "none"
        default:alertStyle = "none"
        }
        
        return alertStyle
    }
    
    private func authorisationStatusToString(status: UNAuthorizationStatus) -> String {
        var result = "notDetermined"
        
        if (status == UNAuthorizationStatus.authorized) {
            result = "authorized"
        } else if (status == UNAuthorizationStatus.denied) {
            result = "denied"
        } else if (status == UNAuthorizationStatus.notDetermined) {
            result = "notDetermined"
        } else if (status == UNAuthorizationStatus.ephemeral) {
            result = "ephemeral"
        } else if #available(iOS 12.0, *) {
            if (status == UNAuthorizationStatus.provisional) {
                result = "provisional"
            }
        }
        return result
    }
    
    private func generateHardwareId() async -> String {
        await uuidProvider.provide()
    }
    
    func loadHardwareId() -> String? {
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
