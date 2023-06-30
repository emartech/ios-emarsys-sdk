
import Foundation
import UserNotifications
@testable import EmarsysSDK
import mimic

struct FakeNotificationCenterWrapper: NotificationCenterWrapper, Mimic {
    
    let fnNotificationSettings = Fn<PushSettings>()
    let fnRequestAuthorization = Fn<Bool>()
    
    func notificationSettings() async -> PushSettings {
        return try! fnNotificationSettings.invoke()
    }
    
    func requestAuthorization() async throws -> Bool {
        return try! fnRequestAuthorization.invoke()
    }
}
