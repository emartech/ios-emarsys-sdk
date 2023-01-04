//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class SdkContext {
    
    @Published
    var sdkState: SdkState = .inactive
    
    var config: Config? = nil // TODO: figure out smth better
    
    func setConfig(config: Config) async {
        self.config = config
    }
    
    func setSdkState(sdkState: SdkState) {
        self.sdkState = sdkState
    }
        
}
