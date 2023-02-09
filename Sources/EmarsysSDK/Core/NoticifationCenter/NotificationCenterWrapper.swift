
import Foundation
import UserNotifications

@SdkActor
protocol NotificationCenterWrapper {
    func notificationSettings() async -> PushSettings
}
