//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation
import Combine

class Deeplink: Api, DeeplinkApi {
    
    let loggingDeeplink: LoggingDeeplink
    let deeplinkInternal: DeeplinkInternal
    
    var active: DeeplinkApi
    var sdkContext: SdkContext
    
    var cancellables = Set<AnyCancellable>()
    
    init(loggingDeeplink: LoggingDeeplink, deeplinkInternal: DeeplinkInternal, sdkContext: SdkContext) {
        self.loggingDeeplink = loggingDeeplink
        self.deeplinkInternal = deeplinkInternal
        self.sdkContext = sdkContext
        active = loggingDeeplink
        sdkContext.$sdkState.sink { [unowned self] state in // TODO: handle warning
            self.setActiveInstance(state: state, features: sdkContext.features)
        }.store(in: &cancellables)
    }
    
    func trackDeeplink(userActivity: NSUserActivity) async throws -> Bool {
        try await self.active.trackDeeplink(userActivity: userActivity)
    }
    
    private func setActiveInstance(state: SdkState, features: [Feature]) {
        switch state {
        case .inactive:
            self.active = loggingDeeplink
        case .onHold, .active:
            self.active = deeplinkInternal
        }
    }
    
}
