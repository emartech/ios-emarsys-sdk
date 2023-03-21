//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class CopyToClipboardActionTests: EmarsysTestCase {
    
    func testExecute_shouldSetTextOnPasteboard() async throws {
        let uiPasteboard =  UIPasteboard.general
        let text = "testText"
        let testAction = CopyToClipboardAction(uiPasteBoard: uiPasteboard, text: text)
        
        try await testAction.execute()
        
        let pasteBoardText = uiPasteboard.string
        
        XCTAssertEqual(pasteBoardText, text)
    }

}
