//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeGenericNetworkClient: NetworkClient, Mimic {
    
    let fnSend = Fn<(Decodable, HTTPURLResponse)>()
    let fnSendWithInput = Fn<(Decodable, HTTPURLResponse)>()
    
    func send<Output>(request: URLRequest) async throws -> (Output, HTTPURLResponse) where Output: Decodable {
        return try fnSend.invoke(params: request) as! (Output, HTTPURLResponse)
    }
    
    func send<Input, Output>(request: URLRequest, body: Input) async throws -> (Output, HTTPURLResponse) where Input: Encodable, Output : Decodable {
        return try fnSendWithInput.invoke(params: request, body) as! (Output, HTTPURLResponse)
    }
    
}
