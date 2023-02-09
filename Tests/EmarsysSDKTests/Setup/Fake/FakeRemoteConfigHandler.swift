import Foundation
@testable import EmarsysSDK

struct FakeRemoteConfigHandler: RemoteConfigHandler, Faked {

    var instanceId: String = UUID().uuidString

    let handle = "handle"

    func handle() async throws {
        return try! handleCall(\.handle)
    }
}
