//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK
import mimic

final class AppStartStateTests: EmarsysTestCase {
    private var state: AppStartState!
    
    @Inject(\.eventClient)
    private var fakeEventClient: FakeEventClient
    

    override func setUpWithError() throws {
        state = AppStartState(eventClient: fakeEventClient)
    }

    func testActivate() async throws {
        let eventName = "app:start"
        
        fakeEventClient
            .when(\.fnSendEvents)
            .thenReturn(EventResponse(message: nil, onEventAction: nil, deviceEventState: nil))
        
        try await state.active()
        
        _ = try fakeEventClient
            .verify(\.fnSendEvents)
            .wasCalled(Arg.eq(eventName), Arg.nil, Arg.eq(EventType.internalEvent))
            .times(times: .eq(1))
    }
}
