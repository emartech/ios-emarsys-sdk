//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeTimestampProvider: DateProvider, Mimic {
    
    let fnProvide = Fn<Date>()
    
    func provide() -> Date {
        return try! fnProvide.invoke()
    }
}
