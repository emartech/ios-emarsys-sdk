//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeTimestampProvider: DateProvider, Fakable {
    
    let instanceId = UUID().description
    
    func provide() async -> Date {
       return try! handleCall()
    }
}
