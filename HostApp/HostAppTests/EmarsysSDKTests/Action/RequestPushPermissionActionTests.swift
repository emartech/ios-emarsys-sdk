//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class RequestPushPermissionActionTests: EmarsysTestCase {
    
    @Inject(\.userNotificationCenterWrapper)
    var fakeUserNotificationCenterWrapper: FakeUserNotificationCenterWrapper
    
    func testExecute_shouldCallRequestPermission_onNotificationCenter() async throws {
        fakeUserNotificationCenterWrapper
            .when(\.fnRequestAuthorization)
            .thenReturn(false)
        
        let application = await UIApplication.shared
        let testAction = RequestPushPermissionAction(application: application, notificationCenterWrapper: fakeUserNotificationCenterWrapper)

        try await testAction.execute()

        _ = try fakeUserNotificationCenterWrapper
            .verify(\.fnRequestAuthorization)
            .times(times: .eq(1))
    }
}
