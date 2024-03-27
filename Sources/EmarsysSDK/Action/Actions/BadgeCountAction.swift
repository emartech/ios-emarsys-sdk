//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

struct BadgeCountAction: Action {
    let actionModel: BadgeCountActionModel
    let application: UIApplication
    
    @MainActor func execute() async throws {
        if actionModel.method == "add" {
            let badgeNumber = application.applicationIconBadgeNumber
            application.applicationIconBadgeNumber = badgeNumber + actionModel.value
        } else {
            application.applicationIconBadgeNumber = actionModel.value
        }
    }
}
