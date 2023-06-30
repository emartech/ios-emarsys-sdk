//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class BadgeCountActionTests: EmarsysTestCase {
    
    @MainActor let application = UIApplication.shared
    
    func testExecute_shouldIncreaseBadgeCount_byGivenValue() async throws {
        throw XCTSkip("UIApplication usage fails in test")
        
        let testValue = 2
        let badgeCountAction = BadgeCountAction(application: application, method: "add", value: testValue)
        
        let startingBadgeCount = await application.applicationIconBadgeNumber
        
        try await badgeCountAction.execute()
        
        let finalBadgeCount = await application.applicationIconBadgeNumber
        
        let difference = finalBadgeCount - startingBadgeCount
        
        XCTAssertEqual(difference, testValue)
    }
    
    func testExecute_shouldSetValue_asBadgeCount_ifMethodIsNot_add() async throws {
        throw XCTSkip("UIApplication usage fails in test")
        
        let testValue = 8
        let badgeCountAction = BadgeCountAction(application: application, method: "set", value: testValue)
        
        try await badgeCountAction.execute()
        
        let resultBadgeCount = await application.applicationIconBadgeNumber
        
        XCTAssertEqual(resultBadgeCount, testValue)
    }
    
}
