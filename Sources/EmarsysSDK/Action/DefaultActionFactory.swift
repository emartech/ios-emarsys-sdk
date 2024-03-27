//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

@SdkActor
struct DefaultActionFactory: ActionFactory {
    
    let eventApi: EventApi
    let userNotificationCenterWrapper: UserNotificationCenterWrapper
    let application: UIApplication
    let uiPasteBoard: UIPasteboard
    let notificationCenterWrapper: NotificationCenterWrapperApi
    
    func create(_ actionModel: any ActionModellable) throws -> any Action {
        switch actionModel {
        case let model as AppEventActionModel: AppEventAction(actionModel: model, notificationCenterWrapper: notificationCenterWrapper)
        case let model as CustomEventActionModel: CustomEventAction(actionModel: model, eventApi: eventApi)
        case let model as BadgeCountActionModel: BadgeCountAction(actionModel: model, application: application)
        case let model as OpenExternalURLActionModel: OpenExternalURLAction(actionModel: model, application: application)
        case _ as RequestPushPermissionActionModel: RequestPushPermissionAction(application: application, notificationCenterWrapper: userNotificationCenterWrapper)
        case let model as CopyToClipboardActionModel: CopyToClipboardAction(actionModel: model, uiPasteBoard: uiPasteBoard)
        case let model as DismissActionModel: DismissAction(actionModel: model, notificationCenterWrapper: notificationCenterWrapper)
        default:
            throw Errors.preconditionFailed(message: "Unknown action type: \(actionModel)")
        }
    }

}
