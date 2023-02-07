
import Foundation
import UserNotifications
@testable import EmarsysSDK

struct FakeNotificationCenterWrapper: NotificationCenterWrapper, Faked {
    
    let instanceId = UUID().uuidString
    
    func notificationSettings() async -> UNNotificationSettings {
        return try! handleCall()
    }
}
