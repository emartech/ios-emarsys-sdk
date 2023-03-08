//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

final class AppStartStateTests: EmarsysTestCase {
    private var state: AppStartState!
    
    @Inject(\.eventClient)
    private var fakeEventClient: FakeEventClient
    

    override func setUpWithError() throws {
        state = AppStartState(eventClient: fakeEventClient)
    }

    func testActivate() async throws {
        let eventName = "app:start"
        var invocations = 0
        var name: String? = nil
        var eventType: EventType? = nil
        
        fakeEventClient.when(\.sendEvents) { invocationCount, params in
            invocations = invocationCount
            name = try params[0].unwrap()
            eventType = try params[2].unwrap()
            
            return EventResponse(message: nil, onEventAction: nil, deviceEventState: nil)
        }
        
        try await state.active()
        
        XCTAssertEqual(invocations, 1)
        XCTAssertEqual(name, eventName)
        XCTAssertEqual(eventType, EventType.internalEvent)
    }
}
