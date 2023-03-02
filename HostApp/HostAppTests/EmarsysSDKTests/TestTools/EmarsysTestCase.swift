//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
class EmarsysTestCase: XCTestCase {

    override class func tearDown() {
        DependencyInjection.tearDown()
    }
    
}
