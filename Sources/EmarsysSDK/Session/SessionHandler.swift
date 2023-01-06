//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
class SessionHandler {
    
    let timestampProvider: TimestampProvider
    
    var contactToken: String? = nil
    var refreshToken: String? = nil
    
    var clientState: String? = nil
    var clientId: String? = nil
    
    init(timestampProvider: TimestampProvider) {
        self.timestampProvider = timestampProvider
    }
    
    var additionalHeaders: [String: String] {
        get async {
            var headers = [String: String]()
            headers["X-Client-State"] = clientState
            headers["X-Client-Id"] = clientId
            headers["X-Contact-Token"] = contactToken
            headers["X-Request-Order"] = "\(await timestampProvider.provide().timeIntervalSince1970 * 1000)"
            return headers
        }
    }
    
}
