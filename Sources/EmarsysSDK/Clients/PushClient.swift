//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct PushClient {
    
    let networkClient: NetworkClient
    let defaultValues: DefaultValues
    let config: Config
    
    func registerPushToken() async throws {
        let body = ["pushToken": "value of the push token"] //TODO: use pushToken
        let request = URLRequest.create(url: try pushTokenUrl(), method: .PUT, body: body.toData())
        let result: (Int, [AnyHashable: Any], Data?) = await networkClient.send(request: request)
        if let clientState = result.1["X-Client-State"] {
            // TODO: store use clientState
        }
    }
    
    func removePushToken() async throws {
        let request = URLRequest.create(url: try pushTokenUrl(), method: .DELETE)
        let result: (Int, [AnyHashable: Any], Data?) = await networkClient.send(request: request)
        if let clientState = result.1["X-Client-State"] {
            // TODO: store use clientState
        }
    }
    
    private func pushTokenUrl() throws -> URL {
        guard let pushTokenUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(config.applicationCode)/client/push-token")) else {
            throw Errors.urlCreationFailed("urlCreationFailed".localized(with: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(config.applicationCode)/client/push-token"))) //TODO: error handling what to do
        }
        return pushTokenUrl
    }
    
}
