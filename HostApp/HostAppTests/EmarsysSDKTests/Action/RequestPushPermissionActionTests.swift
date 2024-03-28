//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class RequestPushPermissionActionTests: EmarsysTestCase {
    
    @Inject(\.application)
    var fakeApplication: FakeApplication
    
    func testExecute_shouldCallRequestPermission_onNotificationCenter() async throws {
        fakeApplication
            .when(\.fnRequestPushPermission)
            .thenReturn(())
        
        let testAction = RequestPushPermissionAction(application: fakeApplication)

        try await testAction.execute()

        _ = try fakeApplication
            .verify(\.fnRequestPushPermission)
            .times(times: .eq(1))
    }
}
