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
        let deviceInfoRequestBody = DeviceInfoRequestBody(platform: deviceInfo.platform, applicationVersion: deviceInfo.applicationVersion, deviceModel: deviceInfo.deviceModel, osVersion: deviceInfo.osVersion, sdkVersion: deviceInfo.sdkVersion, language: deviceInfo.language, timezone: deviceInfo.timezone)
        
        let request = try URLRequest.create(url: url, method: .POST)
        
        do {
            let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request, body: deviceInfoRequestBody)
        } catch Errors.NetworkingError.failedRequest(let response) {
            throw Errors.UserFacingRequestError.registerClientFailed(url: String(describing: response.url?.absoluteString))
        }
    }
}
