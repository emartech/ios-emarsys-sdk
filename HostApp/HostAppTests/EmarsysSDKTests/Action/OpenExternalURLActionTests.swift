//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class OpenExternalURLActionTests: EmarsysTestCase {
    
    @Inject(\.application)
    var fakeApplication: FakeApplication

    func testExecute_shouldCall_openURL_onApplication() async throws {
        let actionModel = OpenExternalURLActionModel(type: "", url: URL(string: "https://emarsys.com")!)
        
        fakeApplication.when(\.fnOpenUrl).thenReturn(())
        
        let action = await OpenExternalURLAction(actionModel: actionModel, application: fakeApplication)
        
        try await action.execute()
        
        _ = try fakeApplication.verify(\.fnOpenUrl).wasCalled(Arg.eq(URL(string: "https://emarsys.com")!))
    }
}
