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
import Combine

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
    private var cancellables: [AnyCancellable] = []
    
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
        
    func registerForAppLifecycle(lifecycle: AppLifecycle, _ closure: @escaping @Sendable () async -> ()) async {
        let nofificationName: Notification.Name = await mapNotificationName(lifecycle: lifecycle)
        let cancellable = NotificationCenter.default
                .publisher(for: nofificationName)
                .sink { _ in
                    Task {
                        await closure()
                    }
                }
        self.cancellables.append(cancellable)
    }
    
    private func mapNotificationName(lifecycle: AppLifecycle) async -> Notification.Name {
        return switch lifecycle {
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

