//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct PushClient {
    
    let networkClient: NetworkClient
    let defaultValues: DefaultValues
    let configContext: SdkContext
    
    func registerPushToken() async throws {
        let body = ["pushToken": "value of the push token"] //TODO: use pushToken
        let request = URLRequest.create(url: try pushTokenUrl(), method: .PUT, body: body.toData())
        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: request)
        
//        switch result {
//        case .success(let response):
//            if let clientState = response.response.allHeaderFields["X-Client-State"] {
//                // TODO: store use clientState
//            }
//        case .failure(let error):
//            // TODO: error handling
//            print("error: \(error)")
//        }
    }
    
    func removePushToken() async throws {
        let request = URLRequest.create(url: try pushTokenUrl(), method: .DELETE)
        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: request)
        
//        switch result {
//        case .success(let response):
//            if let clientState = response.response.allHeaderFields["X-Client-State"] {
//                // TODO: store use clientState
//            }
//        case .failure(let error):
//            // TODO: error handling
//            print("error: \(error)")
//        }
    }
    
    private func pushTokenUrl() throws -> URL {
        guard let pushTokenUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(configContext.config?.applicationCode)/client/push-token")) else {
            throw Errors.urlCreationFailed("urlCreationFailed".localized(with: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(configContext.config?.applicationCode)/client/push-token"))) //TODO: error handling what to do
        }
        return pushTokenUrl
    }
    
}
