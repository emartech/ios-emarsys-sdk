//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
struct DefaultDeviceClient: DeviceClient {
    let emarsysClient: NetworkClient
    let sdkContext: SdkContext
    let deviceInfoCollector: DeviceInfoCollector
    
    func registerClient() async {
//            guard let config = sdkContext.config else {
//                return // TODO: error handling
//            }
//            guard let clientRegistrationUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(config.applicationCode)/client")) else {
//                return // TODO: error handling
//            }
//            let deviceInfo = await deviceInfoCollector.collectInfo()
//            let request = URLRequest.create(url: clientRegistrationUrl, method: .POST)
//            let _ = await send(request: request, encodableBody: deviceInfo)
        }
}
