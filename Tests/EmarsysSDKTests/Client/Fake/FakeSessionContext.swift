//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

class FakeSessionContext: SessionContext {
    
    override var additionalHeaders: [String : String] {
        get async {
            return [
                "X-Client-State": "testClientState",
                "X-Client-Id": "testClientId",
                "X-Contact-Token": "testContactToken",
                "X-Request-Order": "\(Date(timeIntervalSince1970: 50000))"
            ]
        }
    }
}
