//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class RequestPushPermissionActionTests: EmarsysTestCase {
    
    @Inject(\.notificationCenterWrapper)
    var fakeNotificationCenterWrapper: FakeNotificationCenterWrapper
    
    func testExecute_shouldCallRequestPermission_onNotificationCenter() async throws {
        fakeNotificationCenterWrapper
            .when(\.fnRequestAuthorization)
            .thenReturn(false)
        
        let application = await UIApplication.shared
        let testAction = RequestPushPermissionAction(application: application, notificationCenterWrapper: fakeNotificationCenterWrapper)

        try await testAction.execute()

        _ = try fakeNotificationCenterWrapper
            .verify(\.fnRequestAuthorization)
            .times(times: .eq(1))
    }
}
