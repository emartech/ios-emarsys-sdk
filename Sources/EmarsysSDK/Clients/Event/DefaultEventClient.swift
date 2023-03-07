//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct DefaultEventClient: EventClient {
    
    let networkClient: NetworkClient
    let sdkContext: SdkContext
    let sessionContext: SessionContext
    let timestampProvider: any DateProvider
    
    func sendEvents(name: String, attributes: [String: String]?) async throws -> EventResponse {
        let url = try sdkContext.createUrl(\.clientServiceBaseUrl, version: "v4", path: "clients/events")
        let eventRequest = EventRequest(dnd: sdkContext.inAppDnd,
                                        events: [
                                            CustomEvent(type: "custom",
                                                        name: name,
                                                        attributes: attributes,
                                                        timeStamp: timestampProvider.provide())
                                        ],
                                        deviceEventState: sessionContext.deviceEventState)
        
        
        let request = URLRequest.create(url: url, method: .POST)
        let result: (EventResponse, HTTPURLResponse) = try await networkClient.send(request: request, body: eventRequest)
        if let des = result.0.deviceEventState {
            self.sessionContext.deviceEventState = des
        }
        return result.0
    }
}
