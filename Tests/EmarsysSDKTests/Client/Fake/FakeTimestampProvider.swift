//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeTimestampProvider: DateProvider, Faked {
    
    let instanceId = UUID().description
    
    let provide = "provide"
    
    func provide() async -> Date {
        return try! handleCall(\.provide)
    }
}
