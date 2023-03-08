//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK


struct FakeEventClient: EventClient, Faked {
    
    var faker = Faker()
    
    let sendEvents = "sendEvents"
    
    func sendEvents(name: String, attributes: [String: String]?, eventType: EventType) async throws -> EventResponse {
        return try handleCall(\.sendEvents, params: name, attributes, eventType)
    }
}
