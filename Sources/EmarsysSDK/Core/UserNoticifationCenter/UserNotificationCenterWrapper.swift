
import Foundation
import UserNotifications

@SdkActor
protocol UserNotificationCenterWrapper {
    func notificationSettings() async -> PushSettings
    
    func requestAuthorization() async throws -> Bool
}
