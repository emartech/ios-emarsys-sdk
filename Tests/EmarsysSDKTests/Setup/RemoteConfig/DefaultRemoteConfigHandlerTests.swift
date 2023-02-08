//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
final class DefaultRemoteConfigHandlerTests: XCTestCase {
    
    @Inject(\.deviceInfoCollector)
    var fakeDeviceInfoCollector: FakeDeviceInfoCollector
    
    var remoteConfigHandler: DefaultRemoteConfigHandler!

    override func setUpWithError() throws {
        remoteConfigHandler = DefaultRemoteConfigHandler(deviceInfoCollector: fakeDeviceInfoCollector)
    }
    
    func testHandle() throws {
        XCTAssertNil(nil)
    }
}
