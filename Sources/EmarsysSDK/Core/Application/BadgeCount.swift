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

struct BadgeCount: BadgeCountApi {
    
    func increase(_ amount: Int) {
#if os(iOS)
        let application = UIApplication.shared
        let badgeCount = application.applicationIconBadgeNumber
        set(badgeCount + amount)
#elseif os(macOS)
        guard let badgeLabel = NSApp.dockTile.badgeLabel else {
            return
        }
        guard let badgeCount = Int(badgeLabel) else {
            return
        }
        set(badgeCount + amount)
#endif
    }
    
    func set(_ value: Int) {
#if os(iOS)
        UIApplication.shared.applicationIconBadgeNumber = value
#elseif os(macOS)
        NSApp.dockTile.badgeLabel = "\(value)"
#endif
    }
    
}
