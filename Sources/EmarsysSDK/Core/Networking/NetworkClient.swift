//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol NetworkClient {
    
    func send<Output: Decodable>(request: URLRequest) async throws -> (Output, HTTPURLResponse)
    func send<Input: Encodable, Output: Decodable>(request: URLRequest, body: Input) async throws -> (Output, HTTPURLResponse)
    
}
