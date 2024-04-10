//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import Combine

@SdkActor
class GenericApi<LoggingApiInstance: ActivationAware, GathererApiInstance: ActivationAware, InternalApiInstance: ActivationAware>: Api {
    
    let loggingInstance: LoggingApiInstance
    let gathererInstance: GathererApiInstance
    let internalInstance: InternalApiInstance
    
    var active: ActivationAware {
        willSet {
            Task {
                try await newValue.activated()
            }
        }
    }
    var sdkContext: SdkContext
    
    var cancellables = Set<AnyCancellable>()
    
    init(loggingInstance: LoggingApiInstance,
         gathererInstance: GathererApiInstance,
         internalInstance: InternalApiInstance,
         sdkContext: SdkContext) {
        self.loggingInstance = loggingInstance
        self.gathererInstance = gathererInstance
        self.internalInstance = internalInstance
        self.active = loggingInstance
        self.sdkContext = sdkContext
        
        sdkContext.$sdkState.sink { [unowned self] state in
            self.setActiveInstance(state: state, features: sdkContext.features)
        }.store(in: &cancellables)
        
        sdkContext.$features.sink { [unowned self] features in
            self.setActiveInstance(state: sdkContext.sdkState, features: features)
        }.store(in: &cancellables)
    }
    
    func internalInstance(features: [Feature]) -> ActivationAware {
        var result: ActivationAware = loggingInstance
        if features.contains(.mobileEngage) || features.contains(.predict) {
            result = internalInstance
        }
        return result
    }
    
    func setActiveInstance(state: SdkState, features: [Feature]) {
        switch state {
        case .active:
            self.active = internalInstance(features: features)
        case .onHold:
            self.active = gathererInstance
        case .inactive:
            self.active = loggingInstance
        }
    }
}
