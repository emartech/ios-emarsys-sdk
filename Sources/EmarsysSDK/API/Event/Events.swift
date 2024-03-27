//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import Combine

typealias EventInstance = ActivationAware & EventApi

@SdkActor
class Events<LoggingInstance: EventInstance, GathererInstance: EventInstance, InternalInstance: EventInstance>: GenericApi<LoggingInstance, GathererInstance, InternalInstance>, EventApi {
        
    func trackCustomEvent(name: String, attributes: [String : String]?) async throws {
        guard let active = self.active as? EventApi else {
            throw Errors.preconditionFailed(message: "Active instance must be EventApi")
        }
        try await active.trackCustomEvent(name: name, attributes: attributes)
    }
    
}
