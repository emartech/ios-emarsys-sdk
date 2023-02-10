

import XCTest
@testable import EmarsysSDK


@SdkActor
final class DefaultPushClientTests: XCTestCase {

    @Inject(\.genericNetworkClient)
    var fakeNetworkClient: FakeGenericNetworkClient
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.sdkLogger)
    var sdkLogger: SdkLogger
    
    var pushClient: PushClient!
    
    override func setUpWithError() throws {
        try! super.setUpWithError()
        
        pushClient = DefaultPushClient(emarsysClient: fakeNetworkClient,
                                       sdkContext: sdkContext,
                                       sdkLogger: sdkLogger)
    }

// TODO: tests
}
