//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeEventClient: EventClient, Mimic {
    
    let fnSendEvents = Fn<EventResponse>()
    
    func sendEvents(name: String, attributes: [String: String]?, eventType: EventType) async throws -> EventResponse {
        return try fnSendEvents.invoke(params: name, attributes, eventType)
    }
}
