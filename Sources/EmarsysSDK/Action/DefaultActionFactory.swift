//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

typealias EventHandler = (_ name: String, _ payLoad: [String:String]?) -> ()
typealias DismissHandler = () -> ()

@SdkActor
struct DefaultActionFactory: ActionFactory {
    let eventApi: EventApi
    let eventHandler: EventHandler
    let dismissHandler: DismissHandler
    let notificationCenterWrapper: NotificationCenterWrapper
    let application: UIApplication
    let uiPasteBoard: UIPasteboard
    
    func create(genericAction: GenericAction) throws -> Action {
        var action: Action
        switch genericAction.type {
        case Constants.ActionTypes.customEvent:
            let name = try genericAction.getSafeName()
            action = CustomEventAction(eventApi: eventApi, name: name, payload: genericAction.payload)
            
        case Constants.ActionTypes.appEvent:
            let name = try genericAction.getSafeName()
            action =  AppEventAction(appEventHandler: eventHandler, name: name, payload: genericAction.payload)
            
        case Constants.ActionTypes.openExternalURL:
            let url = try genericAction.getSafeURL()
            action =  OpenExternalURLAction(url: url, application: application)

        case Constants.ActionTypes.buttonClicked:
            action =  ButtonClickedAction()
            
        case Constants.ActionTypes.dismiss:
            action =  DismissAction(dismissHandler: dismissHandler)

        case Constants.ActionTypes.requestPushPermission:
            action =  RequestPushPermissionAction(application: application, notificationCenterWrapper: notificationCenterWrapper)
            
        case Constants.ActionTypes.badgeCount:
            let method = try genericAction.getSafeMethod()
            let value = try genericAction.getSafeValue()
            action =  BadgeCountAction(application: application, method: method, value: value)
            
        case Constants.ActionTypes.copyToClipboard:
            let text = try genericAction.getSafeText()
            action =  CopyToClipboardAction(uiPasteBoard: uiPasteBoard, text: text)
            
        default:
            throw Errors.preconditionFailed(message: "Unknown action type: \(genericAction.type)")
        }
        return action
    }
}
