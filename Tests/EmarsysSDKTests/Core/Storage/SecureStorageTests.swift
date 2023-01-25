//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class SecureStorageTests: XCTestCase {
    let testKey = "test"
    var secureStorage: SecureStorage!

    override func setUpWithError() throws {
        secureStorage = SecureStorage()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
