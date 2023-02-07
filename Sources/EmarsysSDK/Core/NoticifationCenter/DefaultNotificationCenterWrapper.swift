

import Foundation
import UserNotifications

struct DefaultNotificationCenterWrapper: NotificationCenterWrapper {
    
    var notificationCenter: UNUserNotificationCenter
    
    func notificationSettings() async -> UNNotificationSettings {
       return await notificationCenter.notificationSettings()
    }
}
