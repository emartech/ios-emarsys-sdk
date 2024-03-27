//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct OnEventActionResponse: Codable {
    let campaignId: String
    let actions: [ActionModel]
}
