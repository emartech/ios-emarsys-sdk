

import XCTest
@testable import EmarsysSDK


@SdkActor
final class DefaultPushClientTests: EmarsysTestCase {

    var pushClient: PushClient!
    
    override func setUpWithError() throws {
        try! super.setUpWithError()
        
        pushClient = DefaultPushClient(emarsysClient: fakeNetworkClient,
                                       sdkContext: sdkContext,
                                       sdkLogger: sdkLogger)
    }
// TODO: tests
}
