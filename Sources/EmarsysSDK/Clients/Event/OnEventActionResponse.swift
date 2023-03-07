//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct OnEventActionResponse: Codable {
    let campaignId: String
    let actions: [GenericAction]
}
