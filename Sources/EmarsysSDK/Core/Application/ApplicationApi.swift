//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

protocol ApplicationApi {
 
    var badgeCount: any BadgeCountApi { get }
    
    var pasteboard: String? { get set }
    
    func openUrl(_ url: URL)
    
    func requestPushPermission() async
    
    func registerForAppLifecycle(lifecycle: AppLifecycle, _ closure: @escaping @Sendable () async -> ()) async
}

extension ApplicationApi {
    
    func registerForAppLifecycle(lifecycle: AppLifecycle, _ closure: @escaping @Sendable () async -> ()) async {
        let notificationName: Notification.Name = await lifecycle.mapNotificationName()
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { _ in
            Task {
                await closure()
            }
        }
    }
}
