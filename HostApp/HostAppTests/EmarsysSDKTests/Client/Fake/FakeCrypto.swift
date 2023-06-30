import Foundation
@testable import EmarsysSDK
import mimic

struct FakeCrypto: Crypto, Mimic {

    let fnVerify = Fn<Bool>()

    func verify(content: Data, signature: Data) -> Bool {
        return try! fnVerify.invoke(params: content, signature)
    }
}
