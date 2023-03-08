//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol EventClient {
    func sendEvents(name: String, attributes: [String: String]?, eventType: EventType) async throws -> EventResponse
}
