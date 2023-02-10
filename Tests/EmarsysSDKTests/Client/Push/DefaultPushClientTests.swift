

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
    
    
    func testRegisterPushToken_shouldRegisterTokenWithEmarsysClient() async throws {
        let pushToken = "testPushToken"
        let expectedBody = ["pushToken": pushToken].toData()

        var count = 0
        var requestUrl: String? = nil
        var sentBody: Data? = nil
        
        fakeNetworkClient.when(\.send) { invocationCount, params in
            count = invocationCount
            let request: URLRequest! = try params[0].unwrap()
            
            requestUrl = request.url?.absoluteString
            sentBody = request.httpBody
            return (Data(), HTTPURLResponse())
        }
        
        try await pushClient.registerPushToken(pushToken)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(requestUrl, "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/push-token")
        XCTAssertEqual(sentBody, expectedBody)
    }
    
    func testRemovePushToken_shouldRemoveTokenWithEmarsysClient() async throws {
        var count = 0
        var requestUrl: String? = nil
        var requestMethod: String? = nil
        
        fakeNetworkClient.when(\.send) { invocationCount, params in
            count = invocationCount
            let request: URLRequest! = try params[0].unwrap()
            
            requestUrl = request.url?.absoluteString
            requestMethod = request.httpMethod
            return (Data(), HTTPURLResponse())
        }
        
        try await pushClient.removePushToken()
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(requestUrl, "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/push-token")
        XCTAssertEqual(requestMethod, "DELETE")
    }
}
