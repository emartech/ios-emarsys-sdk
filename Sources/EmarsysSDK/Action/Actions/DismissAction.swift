//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct DismissAction: Action {
    let actionModel: DismissActionModel
    let notificationCenterWrapper: NotificationCenterWrapperApi
    
    func execute() async throws {
        if let topic = actionModel.topic {
            notificationCenterWrapper.post(topic, object: ())
        }
    }
}
