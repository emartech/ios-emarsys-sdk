import Foundation
@testable import EmarsysSDK
import mimic

struct FakeRemoteConfigHandler: RemoteConfigHandler, Mimic {

    let fnHandle = Fn<()>()
    
    func handle() async throws {
        return try fnHandle.invoke()
    }
}
