//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class SdkContext {
    
    @Published
    var sdkState: SdkState = .inactive
    
    @Published
    var features: [Feature] = [Feature]()
    
    var inAppDnd: Bool = false
    
    var config: EmarsysConfig? = nil // TODO: figure out smth better
    
    func setConfig(config: EmarsysConfig) {
        self.config = config
    }
    
    func setSdkState(sdkState: SdkState) {
        self.sdkState = sdkState
    }
    
    func setFeatures(features: [Feature]) {
        self.features = features
    }
        
}
