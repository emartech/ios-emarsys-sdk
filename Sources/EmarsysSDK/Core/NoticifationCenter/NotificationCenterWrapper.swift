
import Foundation
import UserNotifications

@SdkActor
protocol NotificationCenterWrapper {
    func notificationSettings() async -> PushSettings
    
    func requestAuthorization() async throws -> Bool
}
