//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class CustomEventActionTests: EmarsysTestCase {
    var customEventAction: CustomEventAction!

    @Inject(\.eventApi)
    var fakeEventApi: FakeEventApi

    func testExecute_callsTrackCustomEvent_onEventApi() async throws {
        fakeEventApi
            .when(\.fnCustomeEvent)
            .thenReturn(())
        
        let testName = "test name"
        let testPayload = ["key":"value"]
        
        customEventAction = CustomEventAction(eventApi: fakeEventApi, name: testName, payload: testPayload)
                
        try await customEventAction.execute()
            
        _ = try fakeEventApi
            .verify(\.fnCustomeEvent)
            .wasCalled(Arg.eq(testName), Arg.eq(testPayload))
    }
    
}
