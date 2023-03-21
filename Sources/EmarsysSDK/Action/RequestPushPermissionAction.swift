//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

struct RequestPushPermissionAction: Action {
    let application: UIApplication
    let notificationCenterWrapper: NotificationCenterWrapper
    
    func execute() async throws {
        await application.registerForRemoteNotifications()
        
        let _ = try await notificationCenterWrapper.requestAuthorization()
        
    }
}
