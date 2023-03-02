
import Foundation
import UserNotifications
@testable import EmarsysSDK

struct FakeNotificationCenterWrapper: NotificationCenterWrapper, Faked {
    
    var faker = Faker()
    
    let notificationSettings = "notificationSettings"
    
    func notificationSettings() async -> PushSettings {
        return try! handleCall(\.notificationSettings)
    }
}
