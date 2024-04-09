//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class EventContext {
    let calls: PersistentList<EventCall>
    
    init(calls: PersistentList<EventCall>) {
        self.calls = calls
    }
}

enum EventCall: Codable, Equatable {
    case trackCustomEvent(String, [String: String]?)
}
