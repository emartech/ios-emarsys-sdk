import Foundation
import UserNotifications

class DefaultNotificationCenterWrapper: NotificationCenterWrapper {

    var notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    func notificationSettings() async -> PushSettings {
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
    }
}
