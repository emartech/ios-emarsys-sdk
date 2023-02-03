

import XCTest
@testable import EmarsysSDK


@SdkActor
final class DefaultPushClientTests: XCTestCase {
    var fakeEmarsysClient: FakeGenericNetworkClient!
    var defaultValues: DefaultValues!
    var sdkContext: SdkContext!
    var fakeTimestampProvider: FakeTimestampProvider!
    var pushClient: PushClient!
    var sdkLogger: SDKLogger!
    
    override func setUpWithError() throws {
        fakeEmarsysClient = FakeGenericNetworkClient()
        defaultValues = DefaultValues(version: "testVersion",
                                      clientServiceBaseUrl: "https://base.me-client.eservice.emarsys.net",
                                      eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                      predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                      deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                      inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                      remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        sdkContext = SdkContext()
        sdkContext.config = EmarsysConfig()
        sdkContext.config?.applicationCode = "EMS11-C3FD3"
        fakeTimestampProvider = FakeTimestampProvider()
        sdkLogger = SDKLogger()
        pushClient = DefaultPushClient(emarsysClient: fakeEmarsysClient,
                                       defaultValues: defaultValues,
                                       sdkContext: sdkContext,
                                       sdkLogger: sdkLogger)
    }
    
    override func tearDownWithError() throws {
        fakeEmarsysClient.tearDown()
        fakeTimestampProvider.tearDown()
    }
    
    func testRegisterPushToken_shouldThrowErrorWhenApplicationCode_isNil() async throws {
        let expectedError = Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        
        sdkContext.config?.applicationCode = nil
        
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)
            
            return (Data(), HTTPURLResponse())
        }
        
        await assertThrows(expectedError: expectedError) {
            try await pushClient.registerPushToken("testPushToken")
        }
    }
    
    func testRegisterPushToken_shouldThrowErrorWhenPushTokenUrlCannotBeCreated() async throws {
        let wrongDefaultValues = DefaultValues(version: "testVersion",
                                               clientServiceBaseUrl: "",
                                               eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                               predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                               deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                               inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                               remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        let pushClientWithWrongDefaultValues = DefaultPushClient(emarsysClient: fakeEmarsysClient,
                                                                 defaultValues: wrongDefaultValues,
                                                                 sdkContext: sdkContext,
                                                                 sdkLogger: sdkLogger)
        let expectedError = Errors.preconditionFailed(message: "Url cannot be created for registerPushTokenRequest!")
        
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)
            
            return (Data(), HTTPURLResponse())
        }
        await assertThrows(expectedError: expectedError) {
            try await pushClientWithWrongDefaultValues.registerPushToken("testPushToken")
        }
    }

    func testRemovePushToken_shouldThrowErrorWhenApplicationCode_isNil() async throws {
        let expectedError = Errors.preconditionFailed(message: "ApplicationCode should not be nil!")

        sdkContext.config?.applicationCode = nil

        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)

            return (Data(), HTTPURLResponse())
        }

        await assertThrows(expectedError: expectedError) {
            try await pushClient.removePushToken()
        }
    }

    func testRemovePushToken_shouldThrowErrorWhenPushTokenUrlCannotBeCreated() async throws {
        let wrongDefaultValues = DefaultValues(version: "testVersion",
                                               clientServiceBaseUrl: "",
                                               eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                               predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                               deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                               inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                               remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        let pushClientWithWrongDefaultValues = DefaultPushClient(emarsysClient: fakeEmarsysClient,
                                                                 defaultValues: wrongDefaultValues,
                                                                 sdkContext: sdkContext,
                                                                 sdkLogger: sdkLogger)
        let expectedError = Errors.preconditionFailed(message: "Url cannot be created for registerPushTokenRequest!")

        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)

            return (Data(), HTTPURLResponse())
        }
        await assertThrows(expectedError: expectedError) {
            try await pushClientWithWrongDefaultValues.removePushToken()
        }
    }
}
