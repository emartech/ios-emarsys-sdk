//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

import Foundation

enum NotificationNames: String {
    case pushTokenArrived = "push_token_arrived"

    func asNotificationName() -> Notification.Name {
        return Notification.Name(self.rawValue)
    }

}