//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK
import mimic

@SdkActor
class EmarsysTestCase: XCTestCase {

    override func tearDownWithError() throws {
        DependencyInjection.tearDown()
    }
    
}
