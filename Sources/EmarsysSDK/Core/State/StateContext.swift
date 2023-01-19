//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol StateContext {
    
    var stateLifecycle: (name: String, lifecycle: StateLifecycle)? { get }
    
}
