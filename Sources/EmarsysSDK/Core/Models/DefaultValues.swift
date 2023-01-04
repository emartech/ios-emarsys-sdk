//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct DefaultValues: Decodable {
    let version: String
    let clientServiceBaseUrl: String
    let eventServiceBaseUrl: String
    let predictBaseUrl: String
    let deepLinkBaseUrl: String
    let inboxBaseUrl: String
    let remoteConfigBaseUrl: String
}
