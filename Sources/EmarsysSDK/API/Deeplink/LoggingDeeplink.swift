//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct LoggingDeeplink: DeeplinkApi {
    
    func trackDeeplink(userActivity: NSUserActivity) async throws -> Bool {
        // log call
        return false
    }
    
}
