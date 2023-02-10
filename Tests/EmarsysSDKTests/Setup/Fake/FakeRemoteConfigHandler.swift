import Foundation
@testable import EmarsysSDK

struct FakeRemoteConfigHandler: RemoteConfigHandler, Faked {

    var faker = Faker()

    let handle = "handle"

    func handle() async throws {
        return try! handleCall(\.handle)
    }
}
