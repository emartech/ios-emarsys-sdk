//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation


struct RemoteConfigResponse: Encodable, Decodable, Equatable {
    let serviceUrls: ServiceUrls
    let logLevel: String
    let features: RemoteConfigFeatures
    var overrides: [String: RemoteConfig]? = nil
}
