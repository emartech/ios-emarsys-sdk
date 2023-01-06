//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct TimestampProvider: Provider {
    
    func provide() async -> Date {
        return Date()
    }
    
}
