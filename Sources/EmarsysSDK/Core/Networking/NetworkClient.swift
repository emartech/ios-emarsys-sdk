//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol NetworkClient {

    func send<Output: Decodable>(request: URLRequest) async -> Result<(response: HTTPURLResponse, parsedBody: Output), Error>
    func send<Output: Decodable, Input: Encodable>(request: URLRequest, encodableBody: Input) async -> Result<(response: HTTPURLResponse, parsedBody: Output), Error>
    func send(request: URLRequest) async -> Result<(response: HTTPURLResponse, data: Data), Error>
    func send<Input: Encodable>(request:URLRequest, encodableBody: Input) async -> Result<(response: HTTPURLResponse, data: Data), Error>
    
}

struct DefaultNetworkClient: NetworkClient {
    
    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    
    func send<Output>(request: URLRequest) async -> Result<(response: HTTPURLResponse, parsedBody: Output), Error> where Output : Decodable {
        var result: Result<(response: HTTPURLResponse, parsedBody: Output), Error>
        do {
            let response = try await session.data(for: request)
            guard let httpUrlResponse = response.1 as? HTTPURLResponse else {
                throw Errors.mappingFailed("notHTTPUrlResponse".localized())
            }
            let body = try decoder.decode(Output.self, from: response.0)
            result = .success((httpUrlResponse, body))
        } catch {
            result = .failure(error)
        }
        return result
    }
    
    func send<Output, Input>(request: URLRequest, encodableBody: Input) async -> Result<(response: HTTPURLResponse, parsedBody: Output), Error> where Output : Decodable, Input : Encodable {
        var result: Result<(response: HTTPURLResponse, parsedBody: Output), Error>
        do {
            var mutableRequest = request
            let requestBody = try encoder.encode(encodableBody)
            mutableRequest.httpBody = requestBody
            let response = try await session.data(for: mutableRequest)
            guard let httpUrlResponse = response.1 as? HTTPURLResponse else {
                throw Errors.mappingFailed("notHTTPUrlResponse".localized())
            }
            let body = try decoder.decode(Output.self, from: response.0)
            result = .success((httpUrlResponse, body))
        } catch {
            result = .failure(error)
        }
        return result
    }
    
    func send(request: URLRequest) async -> Result<(response: HTTPURLResponse, data: Data), Error> {
        var result: Result<(response: HTTPURLResponse, data: Data), Error>
        do {
            let response = try await session.data(for: request)
            guard let httpUrlResponse = response.1 as? HTTPURLResponse else {
                throw Errors.mappingFailed("notHTTPUrlResponse".localized())
            }
            result = .success((httpUrlResponse, response.0))
        } catch {
            result = .failure(error)
        }
        return result
    }
    
    func send<Input>(request: URLRequest, encodableBody: Input) async -> Result<(response: HTTPURLResponse, data: Data), Error> where Input : Encodable {
        var result: Result<(response: HTTPURLResponse, data: Data), Error>
        do {
            var mutableRequest = request
            let requestBody = try encoder.encode(encodableBody)
            mutableRequest.httpBody = requestBody
            let response = try await session.data(for: mutableRequest)
            guard let httpUrlResponse = response.1 as? HTTPURLResponse else {
                throw Errors.mappingFailed("notHTTPUrlResponse".localized())
            }
            result = .success((httpUrlResponse, response.0))
        } catch {
            result = .failure(error)
        }
        return result
    }
    
}
