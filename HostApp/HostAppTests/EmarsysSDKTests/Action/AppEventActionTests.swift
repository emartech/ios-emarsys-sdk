//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class AppEventActionTests: EmarsysTestCase {
  
    func testExecute_shouldCall_appEventHandler() async throws {
        let testName = "testName"
        let testPayload = ["key":"value"]
        
        var resultName: String? = nil
        var resultPayload: [String:String]? = nil
        
        let testHandler: EventHandler = { name, payload in
            resultName = name
            resultPayload = payload
        }
        
        let appEventAction = AppEventAction(appEventHandler: testHandler, name: testName, payload: testPayload)
        
        try await appEventAction.execute()
        
        XCTAssertEqual(resultName, testName)
        XCTAssertEqual(resultPayload, testPayload)
    }

}
