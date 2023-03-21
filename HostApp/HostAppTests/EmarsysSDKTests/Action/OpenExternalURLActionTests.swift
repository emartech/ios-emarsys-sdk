//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class OpenExternalURLActionTests: EmarsysTestCase {

    func testExecute_shouldCall_openURL_onApplication() async throws {
        let url = URL(string: "https://emarsys.com")
        let openExternalURLAction = await OpenExternalURLAction(url: url!, application: UIApplication.shared.self)
        
        try await openExternalURLAction.execute()
        
    }
}
