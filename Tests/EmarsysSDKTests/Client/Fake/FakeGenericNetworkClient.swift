//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeGenericNetworkClient: NetworkClient, Fakable {
    
    var instanceId = UUID().description
    
    var send: String = "send"
    var sendWithBody: String = "sendWithBody"
    
    func send<Output>(request: URLRequest) async throws -> (Output, HTTPURLResponse) where Output : Decodable {
        return try handleCall(\.send, params: request)
    }
    
    func send<Input, Output>(request: URLRequest, body: Input) async throws -> (Output, HTTPURLResponse) where Input : Encodable, Output : Decodable {
        return try handleCall(\.sendWithBody, params: request, body)
    }
    
}
