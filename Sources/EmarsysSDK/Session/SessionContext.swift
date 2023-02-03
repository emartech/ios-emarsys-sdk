//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
class SessionContext {
    
    let timestampProvider: any DateProvider
//    let secStore: SecStore
    
    var contactToken: String? = nil
//    {
//        didSet {
//            if oldValue != contactToken {
//                try? secStore.put(data: contactToken?.data(using: .utf8), key: "contactToken")
//            }
//        }
//    }
    
    var refreshToken: String? = nil
    
    var clientState: String? = nil
    var clientId: String? = nil

    var deviceEventState: [String: Any]? = nil
    
    init(timestampProvider: any DateProvider) {
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
