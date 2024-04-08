//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
import Foundation
#if canImport(Cocoa)
import Cocoa
import UserNotifications
#endif

#if os(macOS)
class MacOSApplication: ApplicationApi {
    
    var badgeCount: any BadgeCountApi
    
    var pasteboard: String? {
        get {
            NSPasteboard.general.string(forType: .string)
        }
        set {
            if let newValue {
                NSPasteboard.general.setString(newValue, forType: .string)
            } else {
                NSPasteboard.general.clearContents()
            }
        }
    }
    
    init(badgeCount: any BadgeCountApi) {
        self.badgeCount = badgeCount
    }
    
    func openUrl(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
    
    func requestPushPermission() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional])
        } catch {
            // TODO: error?
        }
    }
}
#endif

