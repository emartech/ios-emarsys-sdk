//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeGenericNetworkClient: NetworkClient, Fakable {
    
    var instanceId: String = {
        return UUID().description
    }()
    
    func send<Output>(request: URLRequest) async throws -> (Output, HTTPURLResponse) where Output : Decodable {
        handleCall(args: request) as! (Output, HTTPURLResponse)
    }
    
    func send<Input, Output>(request: URLRequest, body: Input) async throws -> (Output, HTTPURLResponse) where Input : Encodable, Output : Decodable {
        handleCall(args: request, body) as! (Output, HTTPURLResponse)
    }
    
}
