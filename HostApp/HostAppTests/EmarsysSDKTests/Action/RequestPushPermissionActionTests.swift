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
        let application = await UIApplication.shared
        let testAction = RequestPushPermissionAction(application: application, notificationCenterWrapper: fakeNotificationCenterWrapper)
        
        var count: Int = 0
        
        fakeNotificationCenterWrapper.when(\.requestAuthorization) { invocationCount, params in
            count = invocationCount
            return true
        }
        
        try await testAction.execute()
        
        XCTAssertEqual(count, 1)
    }
}
