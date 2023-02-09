//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation


struct RemoteConfig: Encodable, Decodable, Equatable {
    let serviceUrls: ServiceUrls?
    let logLevel: String?
    let features: RemoteConfigFeatures?
}

struct ServiceUrls: Encodable, Decodable, Equatable {
    var eventService: String? = nil
    var clientService: String? = nil
    var predictService: String? = nil
    var deepLinkService: String? = nil
    var inboxService: String? = nil
}

struct RemoteConfigFeatures: Encodable, Decodable, Equatable {
    var mobileEngage: Bool? = nil
    var predict: Bool? = nil
}
