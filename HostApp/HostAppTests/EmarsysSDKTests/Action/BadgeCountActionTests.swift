//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class BadgeCountActionTests: EmarsysTestCase {
    
    @Inject(\.application)
    var fakeApplication: FakeApplication
    
    func testExecute_shouldIncreaseBadgeCount_byGivenValue() async throws {
        let actionModel = BadgeCountActionModel(type: "", method: "add", value: 2)
        
        let badgeCountAction = BadgeCountAction(actionModel: actionModel, application: fakeApplication)
        
        (fakeApplication.badgeCount as? FakeBadgeCount)?.when(\.fnIncrease).thenReturn(())

        try await badgeCountAction.execute()

        _ = try (fakeApplication.badgeCount as? FakeBadgeCount)?.verify(\.fnIncrease).wasCalled(Arg.eq(2))
    }
    
    func testExecute_shouldSetValue_asBadgeCount_ifMethodIsNot_add() async throws {
        let actionModel = BadgeCountActionModel(type: "", method: "set", value: 8)
        
        let badgeCountAction = BadgeCountAction(actionModel: actionModel, application: fakeApplication)
        
        (fakeApplication.badgeCount as? FakeBadgeCount)?.when(\.fnSet).thenReturn(())

        try await badgeCountAction.execute()

        _ = try (fakeApplication.badgeCount as? FakeBadgeCount)?.verify(\.fnSet).wasCalled(Arg.eq(8))
    }
    
}
