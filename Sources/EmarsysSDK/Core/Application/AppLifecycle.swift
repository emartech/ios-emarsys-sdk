//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif


enum AppLifecycle {
    case didBecomeActive
    case didEnterBackground
}

extension AppLifecycle {
    func mapNotificationName() async -> Notification.Name {
        return switch self {
        case .didBecomeActive: await {
            #if os(iOS)
            await UIApplication.didBecomeActiveNotification
            #elseif os(macOS)
            await NSApplication.didBecomeActiveNotification
            #endif
        }()
            
        case .didEnterBackground: await {
            #if os(iOS)
            await UIApplication.didEnterBackgroundNotification
            #elseif os(macOS)
            // TODO: check if we want to use didHideNotification
            await NSApplication.didResignActiveNotification
            #endif
        }()
        }
    }
}
