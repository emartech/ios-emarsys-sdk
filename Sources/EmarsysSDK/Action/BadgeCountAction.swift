//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

struct BadgeCountAction: Action {
    let application: UIApplication
    let method: String
    let value: Int
    
    @MainActor func execute() async throws {
        if method == "add" {
            let badgeNumber = application.applicationIconBadgeNumber
            application.applicationIconBadgeNumber = badgeNumber + value
        } else {
            application.applicationIconBadgeNumber = value
        }
    }
}
