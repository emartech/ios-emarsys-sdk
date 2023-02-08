//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation


struct RemoteConfig: Encodable, Decodable, Equatable {
    let serviceUrls: ServiceUrls
    let logLevel: String
    let features: RemoteConfigFeatures
}

struct ServiceUrls: Encodable, Decodable, Equatable {
    let eventService: String
    let clientService: String
    let predictService: String
    let deepLinkService: String
    let inboxService: String
}

struct RemoteConfigFeatures: Encodable, Decodable, Equatable {
    let mobileEngage: Bool
    let predict: Bool
}