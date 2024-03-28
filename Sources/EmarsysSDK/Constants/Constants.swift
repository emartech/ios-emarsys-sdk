//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct Constants {
    
    struct AppStart {
        static let appStartEventName = "app:start"
    }
    
    struct Push {
        static let pushToken = "pushToken"
        static let lastSentPushToken = "lastSentPushToken"
    }
    
    struct Contact {
        static let contactToken = "contactToken"
        static let contactFieldId = "contactFieldId"
        static let contactFieldValue = "contactFieldValue"
        static let openIdToken = "openIdToken"
    }
    
    struct Logger {
        static let category = "EmarsysSDK"
        static let subsystem = "com.emarsys"
        static let maxColumns = 8
    }

    struct ActionTypes {
        static let customEvent = "MECustomEvent"
        static let appEvent = "MEAppEvent"
        static let openExternalURL = "OpenExternalUrl"
        static let buttonClicked = "ButtonClicked"
        static let dismiss = "Dismiss"
        static let requestPushPermission = "RequestPushPermission"
        static let badgeCount = "BadgeCount"
        static let copyToClipboard = "CopyToClipboard"
    }
}