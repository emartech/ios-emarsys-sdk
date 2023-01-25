//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct EmarsysClient: NetworkClient {
  
    let networkClient: NetworkClient
    let deviceInfoCollector: DeviceInfoCollector
    let defaultValues: DefaultValues
    let sdkContext: SdkContext
    var sessionContext: SessionContext
    
    func send<Output>(request: URLRequest) async throws -> (Output, HTTPURLResponse) where Output: Decodable {
        let extendedRequest = await extendRequest(request: request)
        var result: (Output, HTTPURLResponse) = try await networkClient.send(request: extendedRequest)
        if result.1.statusCode == 401 {
            let contactToken = try await refreshToken()
            sessionContext.contactToken = contactToken
            let updatedRequest = await extendRequest(request: request)
            result = try await networkClient.send(request: updatedRequest)
        }
        return result
    }
    
    func send<Output, Input>(request: URLRequest, body encodableBody: Input) async throws -> (Output, HTTPURLResponse) where Output : Decodable, Input : Encodable {
        let extendedRequest = await extendRequest(request: request)
        var result: (Output, HTTPURLResponse) = try await networkClient.send(request: extendedRequest, body: encodableBody)
        if result.1.statusCode == 401 {
            let contactToken = try await refreshToken()
            sessionContext.contactToken = contactToken
            let updatedRequest = await extendRequest(request: request)
            result = try await networkClient.send(request: updatedRequest, body: encodableBody)
        }
        return result
    }
    
    private func refreshToken() async throws -> String {
        guard let config = sdkContext.config else {
            throw Errors.preconditionFailed("preconditionFailed".localized(with: "Config must not be nil"))
        }
        let url = defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(config.applicationCode)/client/contact-token")
        guard let refreshTokenURL = URL(string: url) else {
            throw Errors.urlCreationFailed("urlCreationFailed".localized(with: url))
        }
        let refreshTokenRequest = URLRequest.create(url: refreshTokenURL, method: .POST, body: ["refreshToken": sessionContext.refreshToken].toData())
        let extendedRefreshTokenRequest = await extendRequest(request: refreshTokenRequest)
        
        let refreshResult: (Data, HTTPURLResponse) = try await networkClient.send(request: extendedRefreshTokenRequest)
        
        let contactToken = refreshResult.0.toDict()["contactToken"]
        guard let contactToken = contactToken as? String else {
            throw Errors.mappingFailed("mappingFailed".localized(with: String(describing: contactToken), String(describing: String.self)))
        }
        return contactToken
    }
    
    private func extendRequest(request: URLRequest) async -> URLRequest {
        var request = request
        let requestHeaders = request.allHTTPHeaderFields
        let additionalHeaders = await sessionContext.additionalHeaders
        request.allHTTPHeaderFields = requestHeaders == nil ? additionalHeaders : requestHeaders! + additionalHeaders
        return request
    }
}
