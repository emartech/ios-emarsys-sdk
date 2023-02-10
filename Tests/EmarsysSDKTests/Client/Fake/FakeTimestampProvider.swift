//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeTimestampProvider: DateProvider, Faked {
    
    var faker = Faker()
    
    let provideFuncName = "provide"
    
    func provide() -> Date {
        return try! handleCall(\.provideFuncName)
    }
}
