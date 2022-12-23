//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol NetworkClient {
    
    func send<Result: Decodable>(request: URLRequest) async -> Result
    func send<Result: Decodable, Input: Encodable>(request: URLRequest, data: Input) async -> Result
    func send(request: URLRequest) async -> (Int, [AnyHashable: Any], Data?)
    func send<Input: Encodable>(request: URLRequest, data: Input) async -> (Int, [AnyHashable : Any], Data?)
    
}

struct DefaultNetworkClient: NetworkClient {
    
    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    
    func send<Result>(request: URLRequest) async -> Result where Result: Decodable {
        let response = try! await session.data(for: request)
        let result = try! decoder.decode(Result.self, from: response.0)
        return result
    }
    
    func send<Result, Input>(request: URLRequest, data: Input) async -> Result where Result: Decodable, Input: Encodable {
        var mutableRequest = request
        let body = try! encoder.encode(data)
        mutableRequest.httpBody = body
        let response = try! await session.data(for: mutableRequest)
        let result = try! decoder.decode(Result.self, from: response.0)
        return result
    }
    
    func send(request: URLRequest) async -> (Int, [AnyHashable : Any], Data?) {
        let response = try! await session.data(for: request)
        let httpUrlResponse = response.1 as! HTTPURLResponse
        return (httpUrlResponse.statusCode, httpUrlResponse.allHeaderFields, response.0)
    }
    
    func send<Input>(request: URLRequest, data: Input) async -> (Int, [AnyHashable : Any], Data?) where Input: Encodable {
        var mutableRequest = request
        let body = try! encoder.encode(data)
        mutableRequest.httpBody = body
        let response = try! await session.data(for: mutableRequest)
        let httpUrlResponse = response.1 as! HTTPURLResponse
        return (httpUrlResponse.statusCode, httpUrlResponse.allHeaderFields, response.0)
    }
    
}
