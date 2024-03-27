//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class DismissActionTests: EmarsysTestCase {

    @Inject(\.notificationCenterWrapper)
    var fakeNotificationCenterWrapper: FakeNotificationCenterWrapper
    
    func testExecute_shouldCall_dismissHandler() async throws {
        let actionModel = DismissActionModel(type: "", topic: "testTopic")
        
        fakeNotificationCenterWrapper.when(\.p).thenReturn(())
        
        let action = DismissAction(actionModel: actionModel, notificationCenterWrapper: fakeNotificationCenterWrapper)
        
        try await action.execute()
        
        _ = try fakeNotificationCenterWrapper.verify(\.p).wasCalled(Arg.eq("testTopic"), Arg.eq(()))
    }

}
