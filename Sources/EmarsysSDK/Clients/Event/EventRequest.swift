//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
struct EventRequest: Codable {
    let dnd: Bool
    let events: [CustomEvent]
    let deviceEventState: Data?
}
