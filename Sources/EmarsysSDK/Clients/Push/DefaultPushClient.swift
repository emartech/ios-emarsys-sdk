//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct DefaultPushClient: PushClient {
    
    let emarsysClient: NetworkClient
    let defaultValues: DefaultValues
    let sdkContext: SdkContext
    var sdkLogger: SdkLogger
    
    func registerPushToken(_ pushToken: String) async throws {
        let body = ["pushToken": pushToken]
        let request = URLRequest.create(url: try pushTokenUrl(), method: .PUT, body: body.toData())
        let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
    }
    
    func removePushToken() async throws {
        let request = URLRequest.create(url: try pushTokenUrl(), method: .DELETE)
        let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
    }
    
    private func pushTokenUrl() throws -> URL {
        guard let applicationCode = sdkContext.config?.applicationCode else {
            throw Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        }
        guard let pushTokenBaseUrl = URL(string: defaultValues.clientServiceBaseUrl) else {
            throw Errors.preconditionFailed(message: "Url cannot be created for registerPushTokenRequest!")
        }
        let pushTokenUrl = pushTokenBaseUrl.appending(path:"/v3/apps/\(applicationCode)/client/push-token")
        return pushTokenUrl
    }
}
