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
        fakeRemoteConfigHandler
            .when(\.fnHandle)
            .thenReturn(())
        
        try await ApplyRemoteConfigState(remoteConfigHandler: fakeRemoteConfigHandler).active()

        _ = try fakeRemoteConfigHandler
            .verify(\.fnHandle)
            .times(times: .eq(1))
    }
}
