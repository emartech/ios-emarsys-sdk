//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class CopyToClipboardActionTests: EmarsysTestCase {
    
    @Inject(\.application)
    var fakeApplication: FakeApplication
    
    func testExecute_shouldSetTextOnPasteboard() async throws {
        let text = "testText"
        
        let actionModel = CopyToClipboardActionModel(type: "", text: text)
        
        let testAction = CopyToClipboardAction(actionModel: actionModel, application: fakeApplication)
        
        try await testAction.execute()
        
        let pasteBoardText = testAction.application.pasteboard
        
        XCTAssertEqual(pasteBoardText, text)
    }

}
