//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import Combine

@SdkActor
class Event: Api, EventApi {
    
    var sdkContext: SdkContext
    
    var cancellables = Set<AnyCancellable>()

    let eventInternal: ActivatableEventApi
    let loggingEvent: ActivatableEventApi
    let gathererEvent: ActivatableEventApi
    
    var active: ActivatableEventApi {
        willSet {
            Task {
                try await newValue.activated()
            }
        }
    }
    
    init(sdkContext: SdkContext,
         eventInternal: ActivatableEventApi,
         loggingEvent: ActivatableEventApi,
         gathererEvent: ActivatableEventApi) {
        self.sdkContext = sdkContext
        self.eventInternal = eventInternal
        self.loggingEvent = loggingEvent
        self.gathererEvent = gathererEvent
        self.active = loggingEvent
        
        sdkContext.$sdkState.sink { [unowned self] state in
            self.setActiveInstance(state: state, features: sdkContext.features)
        }.store(in: &cancellables)
        
        sdkContext.$features.sink { [unowned self] features in
            self.setActiveInstance(state: sdkContext.sdkState, features: features)
        }.store(in: &cancellables)
    }
    
    func trackCustomEvent(name: String, attributes: [String : String]?) async throws {
        try await self.active.trackCustomEvent(name: name, attributes: attributes)
    }
    
    private func setActiveInstance(state: SdkState, features: [Feature]) {
        switch state {
        case .active:
            if features.contains(Feature.mobileEngage) {
                self.active = eventInternal
            } else {
                self.active = loggingEvent
            }
        case .onHold:
            self.active = gathererEvent
        case .inactive:
            self.active = loggingEvent
        }
    }
    
}
