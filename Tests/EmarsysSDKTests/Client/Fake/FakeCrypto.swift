import Foundation
@testable import EmarsysSDK

struct FakeCrypto: Crypto, Faked {

    let instanceId = UUID().description

    let verify: String = "verify"

    func verify(content: Data, signature: Data) -> Bool {
        return try! handleCall(\.verify, params: content,signature)
    }
}
