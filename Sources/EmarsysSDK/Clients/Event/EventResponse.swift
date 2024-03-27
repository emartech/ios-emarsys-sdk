//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct EventResponse: Codable {
    let message: [String: String]?
    let onEventAction: OnEventActionResponse?
    let deviceEventState: String?
}
