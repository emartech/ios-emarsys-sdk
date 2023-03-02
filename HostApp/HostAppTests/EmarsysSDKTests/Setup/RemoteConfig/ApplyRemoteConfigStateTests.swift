//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
import XCTest
@testable import EmarsysSDK

final class ApplyRemoteConfigStateTests: EmarsysTestCase {

    @Inject(\.remoteConfigHandler)
    var fakeRemoteConfigHandler: FakeRemoteConfigHandler

    func testActive_shouldCallRemoteConfigHandler() async throws {
        var count = 0
        fakeRemoteConfigHandler.when(\.handle) { invocationCount, params in
            count = invocationCount
        }
        try await ApplyRemoteConfigState(remoteConfigHandler: fakeRemoteConfigHandler).active()

        XCTAssertEqual(count, 1)
    }
}
