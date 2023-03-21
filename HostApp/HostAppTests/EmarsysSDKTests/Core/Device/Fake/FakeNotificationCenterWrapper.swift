
import Foundation
import UserNotifications
@testable import EmarsysSDK

struct FakeNotificationCenterWrapper: NotificationCenterWrapper, Faked {
    
    var faker = Faker()
    
    let notificationSettings = "notificationSettings"
    let requestAuthorization = "requestAuthorization"
    
    func notificationSettings() async -> PushSettings {
        return try! handleCall(\.notificationSettings)
    }
    
    func requestAuthorization() async throws -> Bool {
        return try! handleCall(\.requestAuthorization)
    }
}
