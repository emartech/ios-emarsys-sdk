//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
struct EventInternal: ActivationAware, EventApi {
    
    let eventContext: EventContext
    let eventClient: EventClient
    let timestampProvider: any DateProvider
    
    func trackCustomEvent(name: String, attributes: [String : String]?) async throws {
        let _ = try await self.eventClient.sendEvents(name: name, attributes: attributes) //TODO: handle result
    }
    
    func activated() async throws {
       try await self.sendGatheredCalls()
    }
    
    private func sendGatheredCalls() async throws {
        for call in eventContext.calls {
            switch call {
            case .trackCustomEvent(let name, let attributes):
                let _ = try await self.eventClient.sendEvents(name: name, attributes: attributes) //TODO: handle result
            }
        }
    }
}
