//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct CustomEventAction: Action {
    let actionModel: CustomEventActionModel
    let eventApi: EventApi
    
    func execute() async throws {
        try await eventApi.trackCustomEvent(name: actionModel.name, attributes: actionModel.payload)
    }
}
