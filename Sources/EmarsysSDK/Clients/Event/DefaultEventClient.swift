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

    func sendEvents(name: String, attributes: [String: String]?, eventType: EventType) async throws -> EventResponse {
        let url = try sdkContext.createUrl(\.eventServiceBaseUrl, version: "v4", path: "/client/events")
        let eventRequest = EventRequest(
                                dnd: sdkContext.inAppDnd,
                                events: [
                                    CustomEvent(type: eventType.rawValue,
                                                name: name,
                                                attributes: attributes,
                                                timestamp: timestampProvider.provide().toUTC())
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
