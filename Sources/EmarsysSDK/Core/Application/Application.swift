//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
import UserNotifications
#endif

class Application: ApplicationApi {
    
    var badgeCount: any BadgeCountApi
    
    var pasteboard: String? {
        get {
#if os(iOS)
            UIPasteboard.general.string
#elseif os(macOS)
            NSPasteboard.general.string(forType: .string)
#endif
        }
        set {
#if os(iOS)
            UIPasteboard.general.string = newValue
#elseif os(macOS)
            if let newValue {
                NSPasteboard.general.setString(newValue, forType: .string)
            } else {
                NSPasteboard.general.clearContents()
            }
#endif
        }
    }
    
    init(badgeCount: any BadgeCountApi) {
        self.badgeCount = badgeCount
    }
    
    func openUrl(_ url: URL) {
#if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
#elseif os(macOS)
        NSWorkspace.shared.open(url)
#endif
    }
    
    func requestPushPermission() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional])
        } catch {
            // TODO: error?
        }
    }
    
}
