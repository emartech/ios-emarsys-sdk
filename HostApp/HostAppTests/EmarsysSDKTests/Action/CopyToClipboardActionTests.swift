//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class CopyToClipboardActionTests: EmarsysTestCase {
    
    func testExecute_shouldSetTextOnPasteboard() async throws {
        throw XCTSkip("UIPasteboard usage fails in test")
        let pasteboard =  UIPasteboard.general
        let text = "testText"
        
        let actionModel = CopyToClipboardActionModel(type: "", text: text)
        
        let testAction = CopyToClipboardAction(actionModel: actionModel, uiPasteBoard: pasteboard)
        
        try await testAction.execute()
        
        let pasteBoardText = pasteboard.string
        
        XCTAssertEqual(pasteBoardText, text)
    }

}
