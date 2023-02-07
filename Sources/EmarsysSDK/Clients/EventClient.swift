//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct EventClient {
    
    let networkClient: NetworkClient
    let secStore: SecureStorage
    let defaultValues: DefaultUrls
    let sdkContext: SdkContext
    let sessionContext: SessionContext
    
    func sendEvents(events: [Event]) async throws -> (inAppMessage: [String: String]?, onEventAction: [String: Any]?)? {
        var inAppMessage: [String: String]? = nil
        var onEventAction: [String: Any]? = nil
        guard let eventSendingUrl = URL(string: defaultValues.eventServiceBaseUrl.appending("/v4/apps/\(sdkContext.config?.applicationCode)/client/events")) else {
            return nil //TODO: error handling what to do
        }
        var body = [String: Any]()
        body["dnd"] = sdkContext.inAppDnd
        body["events"] = events.map() { event in
            var eventDict: [String: Any] = [
                "type": event.type,
                "name": event.name,
                "timestamp": event.timeStamp.toUTC()
            ]
            eventDict["attributes"] = event.payload
            return eventDict
        }
        body["deviceEventState"] = sessionContext.deviceEventState
        
        let request = URLRequest.create(url: eventSendingUrl, method: .POST, body: body.toData())
        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: request)
//        switch result {
//        case .success(let response):
//            let body = response.data.toDict()
//            if let deviceEventState = body["deviceEventState"] as? [String: Any] {
//                self.sessionHandler.deviceEventState = deviceEventState
//            }
//            if let message = body["message"] as? [String: String] {
//                inAppMessage = message
//            }
//            if let actions = body["onEventAction"] as? [String: Any] {
//                onEventAction = actions
//            }
//        case .failure(let error):
//            // TODO: error handling
//            print("error: \(error)")
//        }
        if inAppMessage == nil && onEventAction == nil {
            return nil
        }
        return (inAppMessage, onEventAction)
    }
    
}
