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
    
    func registerClient() async throws {
        let url = try sdkContext.createUrl(\.clientServiceBaseUrl, path: "/client")
        let deviceInfo = await deviceInfoCollector.collect()
        let request = URLRequest.create(url: url, method: .POST)
        
        do {
            let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request, body: deviceInfo)
        } catch Errors.NetworkingError.failedRequest(let response) {
            throw Errors.UserFacingRequestError.registerClientFailed(url: String(describing: response.url?.absoluteString))
        }
    }
}
