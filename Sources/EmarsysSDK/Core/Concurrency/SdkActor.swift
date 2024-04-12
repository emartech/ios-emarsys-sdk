//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@globalActor
actor SdkActor {
    
    static let shared = SdkActor()
    
    func run(_ runnable: () async -> (Void)) async {
        await runnable()
    }
}
