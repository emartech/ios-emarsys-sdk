//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct BadgeCountAction: Action {
    let actionModel: BadgeCountActionModel
    let application: ApplicationApi
    
    func execute() async throws {
        if actionModel.method == "add" {
            application.badgeCount.increase(actionModel.value)
        } else {
            application.badgeCount.set(actionModel.value)
        }
    }
}
