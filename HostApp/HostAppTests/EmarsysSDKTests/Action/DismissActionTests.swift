//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class DismissActionTests: EmarsysTestCase {

    func testExecute_shouldCall_dismissHandler() async throws {
        var counter = 0
        
        let testHandler = {
            counter = 1
        }
        
        let testAction = DismissAction(dismissHandler: testHandler)
        
        try await testAction.execute()
        
        XCTAssertEqual(counter, 1)
    }

}
