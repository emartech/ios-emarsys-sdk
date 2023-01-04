//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

class Deeplink: Api, DeeplinkApi {
    
    let loggingDeeplink: LoggingDeeplink
    let deeplinkInternal: DeeplinkInternal
    
    var active: DeeplinkApi
    var sdkContext: SdkContext
    
    init(loggingDeeplink: LoggingDeeplink, deeplinkInternal: DeeplinkInternal, sdkContext: SdkContext) {
        self.loggingDeeplink = loggingDeeplink
        self.deeplinkInternal = deeplinkInternal
        self.sdkContext = sdkContext
        active = loggingDeeplink
        sdkContext.$sdkState.sink { state in
            switch state {
            case .inactive:
                self.active = loggingDeeplink
            case .onHold, .active:
                self.active = deeplinkInternal
            }
        }
    }
    
    func trackDeeplink(userActivity: NSUserActivity) async throws -> Bool {
        try await self.active.trackDeeplink(userActivity: userActivity)
    }
    
}
