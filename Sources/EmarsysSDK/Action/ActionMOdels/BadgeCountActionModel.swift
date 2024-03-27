//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct BadgeCountActionModel: ActionModellable {
    let type: String
    
    let method: String
    let value: Int
}
