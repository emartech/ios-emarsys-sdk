//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct EmarsysClient: NetworkClient, DeviceClient {
    
    let networkClient: NetworkClient
    let deviceInfoCollector: DeviceInfoCollector
    let defaultValues: DefaultValues
    let sdkContext: SdkContext
    var sessionHandler: SessionHandler
    
    func send<Output>(request: URLRequest) async -> Result<(response: HTTPURLResponse, parsedBody: Output), Error> where Output : Decodable {
        return try! await retry {
            let extendedRequest = await extendRequest(request: request)
            let result: Result<(response: HTTPURLResponse, parsedBody: Output), Error> = await networkClient.send(request: extendedRequest)
            handleResult(result: result)
            return result
        }
    }
    
    func send<Output, Input>(request: URLRequest, encodableBody: Input) async -> Result<(response: HTTPURLResponse, parsedBody: Output), Error> where Output : Decodable, Input : Encodable {
        return try! await retry {
            let extendedRequest = await extendRequest(request: request)
            let result: Result<(response: HTTPURLResponse, parsedBody: Output), Error> = await networkClient.send(request: extendedRequest, encodableBody: encodableBody)
            handleResult(result: result)
            return result
        }
    }
    
    func send(request: URLRequest) async -> Result<(response: HTTPURLResponse, data: Data), Error> {
        return try! await retry {
            let extendedRequest = await extendRequest(request: request)
            let result: Result<(response: HTTPURLResponse, data: Data), Error> = await networkClient.send(request: extendedRequest)
            handleResult(result: result)
            return result
        }
    }
    
    func send<Input>(request: URLRequest, encodableBody: Input) async -> Result<(response: HTTPURLResponse, data: Data), Error> where Input : Encodable {
        return try! await retry {
            let extendedRequest = await extendRequest(request: request)
            let result: Result<(response: HTTPURLResponse, data: Data), Error> = await networkClient.send(request: extendedRequest, encodableBody: encodableBody)
            return result
        }
    }
    
    func registerClient() async {
        guard let config = sdkContext.config else {
            return // TODO: error handling
        }
        guard let clientRegistrationUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(config.applicationCode)/client")) else {
            return // TODO: error handling
        }
        let deviceInfo = await deviceInfoCollector.collectInfo()
        let request = URLRequest.create(url: clientRegistrationUrl, method: .POST)
        let _ = await send(request: request, encodableBody: deviceInfo)
    }
    
    private func refreshExpiredToken() async {
        guard let refreshToken = sessionHandler.refreshToken else {
            return  // TODO: error handling
        }
        guard let config = sdkContext.config else {
            return // TODO: error handling
        }
        guard let refreshTokenUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(config.applicationCode)/client/contact-token")) else {
            return // TODO: error handling
        }
        let request = URLRequest.create(url: refreshTokenUrl, method: .POST, body: ["refreshToken": refreshToken].toData())
        let result = await send(request: request)
        switch result {
        case .success(let response):
            if let body = response.data.toDict() as? [String: String] {
                self.sessionHandler.contactToken = body["contactToken"]
            }
        case .failure(let error):
            // TODO: error handling
            print("error: \(error)")
        }
    }
    
    private func retry<T>(maxAttempts: Int = 3, handler: () async throws -> T) async throws -> T {
        var result: T
        do {
            result = try await handler()
        } catch Errors.tokenExpired {
            let _ = await refreshExpiredToken()
            if maxAttempts > 0 {
                result = try await retry(maxAttempts: maxAttempts - 1, handler: handler)
            } else {
                throw Errors.tokenExpired
                // TODO: handle error
            }
        } catch {
            throw error
            // TODO: handle error
        }
        return result
    }
    
    private func extendRequest(request: URLRequest) async -> URLRequest {
        var request = request
        let requestHeaders = request.allHTTPHeaderFields
        let additionalHeaders = await sessionHandler.additionalHeaders
        request.allHTTPHeaderFields = requestHeaders == nil ? additionalHeaders : requestHeaders! + additionalHeaders
        return request
    }
    
    private func handleResult<T>(result: Result<(response: HTTPURLResponse, parsedBody: T), Error>) {
        switch result {
        case .success(let response):
            storeClientState(response: response.response)
        case .failure(let error):
            handleError(error: error)
        }
    }
    
    private func handleResult(result: Result<(response: HTTPURLResponse, data: Data), Error>) {
        switch result {
        case .success(let response):
            storeClientState(response: response.response)
        case .failure(let error):
            handleError(error: error)
        }
    }
    
    private func storeClientState(response: HTTPURLResponse) {
        if let clientState = response.allHeaderFields["X-Client-State"] as? String {
            sessionHandler.clientState = clientState
        }
    }
    
    private func handleError(error: Error) {
        // TODO: error handling
        print("error: \(error)")
    }
    
}
