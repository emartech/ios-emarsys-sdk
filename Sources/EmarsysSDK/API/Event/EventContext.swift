//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class EventContext {
    var calls = [EventCall]()
}

enum EventCall: Equatable {
    case trackCustomEvent(String, [String: String]?)
}
