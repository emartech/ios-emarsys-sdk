//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeBadgeCount: BadgeCountApi, Mimic {
    
    let fnIncrease = Fn<()>()
    let fnSet = Fn<()>()
    
    func increase(_ amount: Int) {
        return try! fnIncrease.invoke(params: amount)
    }
    
    func set(_ value: Int) {
        return try! fnSet.invoke(params: value)
    }
    
}
