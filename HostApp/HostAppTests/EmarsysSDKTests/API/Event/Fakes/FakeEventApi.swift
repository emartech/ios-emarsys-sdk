//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeEventApi: EventInstance, Mimic {
    
    let fnCustomeEvent = Fn<()>()
    
    func trackCustomEvent(name: String, attributes: [String : String]?) async throws {
        return try fnCustomeEvent.invoke(params: name, attributes)
    }
}
