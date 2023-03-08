//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation


@SdkActor
struct AppStartState: State {
    let eventClient: EventClient
    
    var name = SetupState.appStart.rawValue
    
    func prepare() {
    }
    
    func active() async throws {
        let _ = try await eventClient.sendEvents(name: Constants.AppStart.appStartEventName, attributes: nil, eventType: EventType.internalEvent)
    }
    
    func relax() {
    }
}
