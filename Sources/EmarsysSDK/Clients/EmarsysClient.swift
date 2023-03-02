//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct EmarsysClient: NetworkClient {
    
    let networkClient: NetworkClient
    let deviceInfoCollector: DeviceInfoCollector
    let defaultUrls: DefaultUrls
    let sdkContext: SdkContext
    var sessionContext: SessionContext
    
    func send<Output>(request: URLRequest) async throws -> (Output, HTTPURLResponse) where Output: Decodable {
        return try await refreshToken() {
            let extendedRequest = await extendRequest(request: request)
            let response : (Output, HTTPURLResponse) = try await networkClient.send(request: extendedRequest)
            handleClientState(response)
            return response
        }
    }
    
    func send<Output, Input>(request: URLRequest, body encodableBody: Input) async throws -> (Output, HTTPURLResponse) where Output : Decodable, Input : Encodable {
        return try await refreshToken() {
            let extendedRequest = await extendRequest(request: request)
            let response : (Output, HTTPURLResponse) = try await networkClient.send(request: extendedRequest, body: encodableBody)
            handleClientState(response)
            return response
        }
    }
    
    private func handleClientState<Output>(_ response: (Output, HTTPURLResponse)) {
        let res = response.1
        if res.isOk() {
            if let headers = res.allHeaderFields as? Dictionary<String, Any> {
                let lowerCasedHeaders = headers.lowerCaseKeys()
                if let clientState = lowerCasedHeaders["x-client-state"] as? String {
                    sessionContext.clientState = clientState
                }
            }
        }
    }
    private func refreshToken<Output>(callback: @escaping () async throws ->(Output, HTTPURLResponse)) async throws -> (Output, HTTPURLResponse) where Output : Decodable {
        var requestResult =  try await callback()
        if requestResult.1.statusCode == 401 {
            let contactToken = try await refreshContactToken()
            sessionContext.contactToken = contactToken
            requestResult = try await callback()
        }
        return requestResult
    }
    
    private func refreshContactToken() async throws -> String {
        let url = try sdkContext.createUrl(\.clientServiceBaseUrl, path: "/client/contact-token")
        let refreshTokenRequest = URLRequest.create(url: url, method: .POST, body: ["refreshToken": sessionContext.refreshToken].toData())
        let extendedRefreshTokenRequest = await extendRequest(request: refreshTokenRequest)
        
        let refreshResult: (Data, HTTPURLResponse) = try await networkClient.send(request: extendedRefreshTokenRequest)
        
        let contactToken = refreshResult.0.toDict()["contactToken"]
        guard let contactToken = contactToken as? String else {
            throw Errors.TypeError.mappingFailed(parameter: String(describing: contactToken), toType: String(describing: String.self))
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
