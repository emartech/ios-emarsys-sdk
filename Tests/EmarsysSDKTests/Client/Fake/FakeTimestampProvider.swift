//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeTimestampProvider: DateProvider, Fakable {
    
    var instanceId: String = {
        return UUID().description
    }()
    
    func provide() async -> Date {
       return handleCall(args: nil) as! Date
    }
}
