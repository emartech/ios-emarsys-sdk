//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct DefaultPushClient: PushClient {
    
    let emarsysClient: NetworkClient
    let sdkContext: SdkContext
    var sdkLogger: SdkLogger
    
    func registerPushToken(_ pushToken: String) async throws {
        let url = try sdkContext.createUrl(\.clientServiceBaseUrl, path: "/client/push-token")
        let body = ["pushToken": pushToken]
        let request = URLRequest.create(url: url, method: .PUT, body: body.toData())
        let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
    }
    
    func removePushToken() async throws {
        let url = try sdkContext.createUrl(\.clientServiceBaseUrl, path: "/client/push-token")
        let request = URLRequest.create(url: url, method: .DELETE)
        let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
    }
    
}
