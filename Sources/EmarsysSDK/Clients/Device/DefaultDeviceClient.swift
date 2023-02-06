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
    let defaultValues: DefaultValues
    
    func registerClient() async throws {
        guard let config = sdkContext.config else {
            throw Errors.preconditionFailed(message: "Config should not be nil!")
        }
        guard let applicationCode = config.applicationCode else {
            throw Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        }
        guard let clientRegistrationBaseUrl = URL(string: defaultValues.clientServiceBaseUrl) else {
            throw Errors.preconditionFailed(message: "Url cannot be created for registerClientRequest!")
        }
        let url = clientRegistrationBaseUrl.appending(path: "/v3/apps/\(applicationCode)/client")
        let deviceInfo = await deviceInfoCollector.collect()
        let request = URLRequest.create(url: url, method: .POST)
        
        do {
            let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request, body: deviceInfo)
        } catch Errors.NetworkingError.failedRequest(let response) {
            throw Errors.UserFacingRequestError.registerClientFailed(url: String(describing: response.url?.absoluteString))
        }
    }
}
