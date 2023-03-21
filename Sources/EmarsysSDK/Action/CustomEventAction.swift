//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct CustomEventAction: Action {
    let eventApi: EventApi
    let name: String
    let payload: [String:String]?
    
    func execute() async throws {
        try await eventApi.trackCustomEvent(name: name, attributes: payload)
    }
}
