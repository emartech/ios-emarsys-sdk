//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol NetworkClient {
    
    func fetch<T: Decodable>() async -> T
    
}

struct DefaultNetworkClient: NetworkClient {
    
    let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.httpCookieStorage = nil
        self.session = URLSession(configuration: configuration)
    }
    
    func fetch<T>() async -> T where T: Decodable {
        let request = URLRequest(url: URL(string: "")!)
        let response = try! await session.data(for: request)
        let decoder = JSONDecoder()
        let result = try! decoder.decode(T.self, from: response.0)
        return result
    }
}
