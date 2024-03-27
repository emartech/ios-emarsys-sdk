//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

final class BadgeCountActionTests: EmarsysTestCase {
    
    @MainActor let application = UIApplication.shared
    
    func testExecute_shouldIncreaseBadgeCount_byGivenValue() async throws {
        throw XCTSkip("UIApplication usage fails in test")
        let actionModel = BadgeCountActionModel(type: "", method: "add", value: 2)
        
        let badgeCountAction = BadgeCountAction(actionModel: actionModel, application: application)
        
        let startingBadgeCount = await application.applicationIconBadgeNumber
        
        try await badgeCountAction.execute()
        
        let finalBadgeCount = await application.applicationIconBadgeNumber
        
        let difference = finalBadgeCount - startingBadgeCount
        
        XCTAssertEqual(difference, 2)
    }
    
    func testExecute_shouldSetValue_asBadgeCount_ifMethodIsNot_add() async throws {
        throw XCTSkip("UIApplication usage fails in test")
        let actionModel = BadgeCountActionModel(type: "", method: "set", value: 8)
        
        let badgeCountAction = BadgeCountAction(actionModel: actionModel, application: application)
        
        try await badgeCountAction.execute()
        
        let resultBadgeCount = await application.applicationIconBadgeNumber
        
        XCTAssertEqual(resultBadgeCount, 8)
    }
    
}
