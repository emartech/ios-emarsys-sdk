//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct AppEventAction: Action {
    let actionModel: AppEventActionModel
    let notificationCenterWrapper: NotificationCenterWrapperApi
    
    func execute() async throws {
        notificationCenterWrapper.post(ActionTopics.appEvent.rawValue, object: Event(name: actionModel.name, attributes: actionModel.payload))
    }
}
