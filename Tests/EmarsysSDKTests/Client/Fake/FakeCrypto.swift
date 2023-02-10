import Foundation
@testable import EmarsysSDK

struct FakeCrypto: Crypto, Faked {

    var faker = Faker()

    let verify: String = "verify"

    func verify(content: Data, signature: Data) -> Bool {
        return try! handleCall(\.verify, params: content,signature)
    }
}
