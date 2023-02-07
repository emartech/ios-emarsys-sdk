
import Foundation
import UserNotifications

protocol NotificationCenterWrapper {
    func notificationSettings() async -> UNNotificationSettings
}
