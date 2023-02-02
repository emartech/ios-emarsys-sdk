//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

struct GenericNetworkClient: NetworkClient {

    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder

    func send<Output: Decodable>(request: URLRequest) async throws -> (Output, HTTPURLResponse) where Output: Decodable {
        let response = try await session.data(for: request)
        guard let httpUrlResponse = response.1 as? HTTPURLResponse else {
            throw Errors.TypeError.mappingFailed(parameter: String(describing: response.1), toType: String(describing: HTTPURLResponse.self))
        }
        
        if !httpUrlResponse.isOk() {
            throw Errors.NetworkingError.failedRequest(response: httpUrlResponse)
        }
        
        var output: Output!
        if Output.self == Data.self {
            output = response.0 as? Output
        } else {
            do {
                output = try decoder.decode(Output.self, from: response.0)
            } catch {
                throw Errors.TypeError.decodingFailed(type: String(describing: Output.self))
            }
        }
        return (output, httpUrlResponse)
    }

    func send<Input, Output: Decodable>(request: URLRequest, body: Input) async throws -> (Output, HTTPURLResponse) where Input: Encodable, Output: Decodable {
        var mutableRequest = request
        do {
            let requestBody = try encoder.encode(body)
            mutableRequest.httpBody = requestBody
        } catch {
            throw Errors.TypeError.encodingFailed(type: String(describing: Input.self))
        }
        return try await send(request: mutableRequest)
    }

}
