//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@globalActor
struct SdkActor {
    actor ActorType { }

    static let shared: ActorType = ActorType()
}
