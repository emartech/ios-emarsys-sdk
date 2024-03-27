import Foundation
import UserNotifications

class DefaultUserNotificationCenterWrapper: UserNotificationCenterWrapper {
    
    var notificationCenter: UNUserNotificationCenter?
    
    init(notificationCenter: UNUserNotificationCenter?) {
        self.notificationCenter = notificationCenter
    }
    
    func notificationSettings() async -> PushSettings {
        if let notificationCenter = notificationCenter {
            let settings = await notificationCenter.notificationSettings()
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
        } else {
            return PushSettings(authorizationStatus: "not available",
                                soundSetting: "not available",
                                badgeSetting: "not available",
                                alertSetting: "not available",
                                notificationCenterSetting: "not available",
                                lockScreenSetting: "not available",
                                carPlaySetting: "not available",
                                alertStyle: "not available",
                                showPreviewsSetting: "not available",
                                criticalAlertSetting: "not available",
                                providesAppNotificationSettings: "not available",
                                scheduledDeliverySetting: "not available",
                                timeSensitiveSetting: "not available"
            )
        }
        
    }
    
    func requestAuthorization() async throws -> Bool {
        if let notificationCenter = notificationCenter {
            return try await notificationCenter.requestAuthorization(options: [UNAuthorizationOptions.sound, UNAuthorizationOptions.alert, UNAuthorizationOptions.badge])
        } else {
            return false
        }
    }
}
