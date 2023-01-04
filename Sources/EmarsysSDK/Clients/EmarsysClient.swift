//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct EmarsysClient {
    
    let networkClient: NetworkClient
    let deviceInfoCollector: DeviceInfoCollector
    let defaultValues: DefaultValues
    let configContext: SdkContext

    func registerClient() async {
        guard let clientRegistrationUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(configContext.config?.applicationCode)/client")) else {
            return //TODO: error handling what to do
        }
        let deviceInfo = await deviceInfoCollector.collectInfo()
        let request = URLRequest.create(url: clientRegistrationUrl, method: .POST)
        let result: (Int, [AnyHashable: Any], Data?) = await networkClient.send(request: request, data: deviceInfo)
        if let clientState = result.1["X-Client-State"] {
            // TODO: store use clientState
        }
    }
    
}
