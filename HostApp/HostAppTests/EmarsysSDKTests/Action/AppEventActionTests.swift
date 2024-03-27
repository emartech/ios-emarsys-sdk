//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class AppEventActionTests: EmarsysTestCase {
    
    @Inject(\.notificationCenterWrapper)
    var fakeNotificationCenterWrapper: FakeNotificationCenterWrapper
  
    func testExecute() async throws {
        let testName = "testName"
        let testPayload = ["key":"value"]
        
        fakeNotificationCenterWrapper.when(\.p).thenReturn(())
        
        let actionModel = AppEventActionModel(type: "", name: testName, payload: testPayload)
        
        let action = AppEventAction(actionModel: actionModel, notificationCenterWrapper: fakeNotificationCenterWrapper)
        
        try await action.execute()
        
        _ = try fakeNotificationCenterWrapper.verify(\.p).wasCalled(Arg.eq(ActionTopics.appEvent.rawValue), Arg.eq(Event(name: testName, attributes: testPayload)))
    }

}
