

import XCTest
@testable import EmarsysSDK


@SdkActor
final class DefaultPushClientTests: EmarsysTestCase {
    
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
        let expectedBody = ["pushToken": pushToken]
        let expectedData = try JSONEncoder().encode(expectedBody)

        var count: Int = 0
        var requestUrl: String? = nil
        var sentBody: Data? = nil

        fakeNetworkClient.when(\.fnSend).replaceFunction { invocationCount, params in
            let request: URLRequest! = params[0]
            requestUrl = request.url?.absoluteString
            sentBody = request.httpBody
            count = invocationCount
            return (Data(), HTTPURLResponse())
        }
        
        try await pushClient.registerPushToken(pushToken)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(requestUrl, "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/push-token")
        XCTAssertEqual(sentBody, expectedData)
    }
    
    func testRemovePushToken_shouldRemoveTokenWithEmarsysClient() async throws {
        var count = 0
        var requestUrl: String? = nil
        var requestMethod: String? = nil
        
        fakeNetworkClient.when(\.fnSend).replaceFunction { invocationCount, params in
            let request: URLRequest! = params[0]
            requestUrl = request.url?.absoluteString
            requestMethod = request.httpMethod
            count = invocationCount
            return (Data(), HTTPURLResponse())
        }
        
        try await pushClient.removePushToken()
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(requestUrl, "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/push-token")
        XCTAssertEqual(requestMethod, "DELETE")
    }
}
