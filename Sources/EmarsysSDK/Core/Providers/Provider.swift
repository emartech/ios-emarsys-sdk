//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol Provider {
    associatedtype Value
    
    func provide() -> Value
}
