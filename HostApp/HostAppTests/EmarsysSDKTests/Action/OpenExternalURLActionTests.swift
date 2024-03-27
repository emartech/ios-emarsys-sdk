//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class OpenExternalURLActionTests: EmarsysTestCase {

    func testExecute_shouldCall_openURL_onApplication() async throws {
        throw XCTSkip("UIPasteboard usage fails in test")
        let actionModel = OpenExternalURLActionModel(type: "", url: URL(string: "https://emarsys.com")!)
        
        let action = await OpenExternalURLAction(actionModel: actionModel, application: UIApplication.shared)
        
        try await action.execute()
    }
}
