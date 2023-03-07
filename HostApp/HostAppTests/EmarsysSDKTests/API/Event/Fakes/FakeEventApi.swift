//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeEventApi: ActivatableEventApi, Faked {
    var faker = Faker()
    
    let trackCustomEvent = "trackCustomEvent"
    
    func trackCustomEvent(name: String, attributes: [String : String]?) async throws {
        return try handleCall(\.trackCustomEvent, params: name, attributes)
    }
}