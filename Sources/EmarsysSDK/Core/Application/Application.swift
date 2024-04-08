//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
class Application: ApplicationApi {
    
    var badgeCount: any BadgeCountApi
    
    var pasteboard: String? {
        get {
            UIPasteboard.general.string
        }
        set {
            UIPasteboard.general.string = newValue
        }
    }
    
    init(badgeCount: any BadgeCountApi) {
        self.badgeCount = badgeCount
    }
    
    func openUrl(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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

