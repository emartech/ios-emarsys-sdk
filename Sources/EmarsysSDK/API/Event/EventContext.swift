//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class EventContext {
    var calls: any RangeReplaceableCollection<EventCall>
    
    init(calls: any RangeReplaceableCollection<EventCall>) {
        self.calls = calls
    }
}

enum EventCall: Codable, Equatable {
    case trackCustomEvent(String, [String: String]?)
}
