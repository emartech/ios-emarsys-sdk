//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class GathererEvent: EventInstance {
    
    var eventContext: EventContext
    
    init(eventContext: EventContext) {
        self.eventContext = eventContext
    }
    
    func trackCustomEvent(name: String, attributes: [String: String]?) async throws {
        self.eventContext.calls.append(.trackCustomEvent(name, attributes))
    }
}
