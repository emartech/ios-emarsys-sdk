//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
class SessionContext {
    
    let timestampProvider: any DateProvider
    let deviceInfoCollector: DeviceInfoCollector
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
    lazy var clientId: String? = {
        deviceInfoCollector.hardwareId()
    }()

    var deviceEventState: [String: Any]? = nil
    
    init(timestampProvider: any DateProvider, deviceInfoCollector: DeviceInfoCollector) {
        self.timestampProvider = timestampProvider
        self.deviceInfoCollector = deviceInfoCollector
    }
    
    var additionalHeaders: [String: String] {
        get async {
            var headers = [String: String]()
            headers["X-Client-State"] = clientState
            headers["X-Client-Id"] = clientId
            headers["X-Contact-Token"] = contactToken
            headers["X-Request-Order"] = "\(timestampProvider.provide().timeIntervalSince1970 * 1000)"
            return headers
        }
    }
    
}
