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
    
    func registerForAppLifecycle(lifecycle: AppLifecycle, _ closure: @Sendable () async -> ()) async
}

protocol BadgeCountApi {
    
    func increase(_ amount: Int)
    
    func set(_ value: Int)
    
}
