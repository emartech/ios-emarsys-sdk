//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol DeeplinkApi {
    
    func trackDeeplink(userActivity: NSUserActivity) async throws -> Bool
    
}
