//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class CustomEventActionTests: EmarsysTestCase {
    var customEventAction: CustomEventAction!

    @Inject(\.eventApi)
    var fakeEventApi: FakeEventApi

    func testExecute_callsTrackCustomEvent_onEventApi() async throws {
        let testName = "test name"
        let testPayload = ["key":"value"]
        
        customEventAction = CustomEventAction(eventApi: fakeEventApi, name: testName, payload: testPayload)
        
        var eventName: String? = nil
        var eventAttributes: [String:String]? = nil
        
        fakeEventApi.when(\.trackCustomEvent) { invocationCount, params in
            eventName = try params[0].unwrap()
            eventAttributes = try params[1].unwrap()
            return
        }
        
        try await customEventAction.execute()
        
        XCTAssertEqual(eventName, testName)
        XCTAssertEqual(eventAttributes, testPayload)
    }
    
}
