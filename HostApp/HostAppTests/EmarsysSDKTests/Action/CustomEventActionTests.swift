//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class CustomEventActionTests: EmarsysTestCase {

    @Inject(\.eventApi)
    var fakeEventApi: FakeEventApi
    
    func testExecute_callsTrackCustomEvent_onEventApi() async throws {
        let testName = "test name"
        let testPayload = ["key":"value"]
        
        fakeEventApi.when(\.fnCustomeEvent).thenReturn(())
        
        let actionModel = CustomEventActionModel(type: "", name: testName, payload: testPayload)
        
        let action = CustomEventAction(actionModel: actionModel, eventApi: fakeEventApi)
                
        try await action.execute()
            
        _ = try fakeEventApi
            .verify(\.fnCustomeEvent)
            .wasCalled(Arg.eq(testName), Arg.eq(testPayload))
    }
    
}
