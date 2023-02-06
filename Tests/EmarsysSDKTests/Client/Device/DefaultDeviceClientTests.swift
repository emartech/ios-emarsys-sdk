//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class DefaultDeviceClientTests: XCTestCase {
    var fakeEmarsysClient: FakeGenericNetworkClient!
    var sdkContext: SdkContext!
    var fakeDeviceInfoCollector: FakeDeviceInfoCollector!
    var defaultDeviceClient: DeviceClient!
    var defaultValues: DefaultValues!
    var deviceInfo: DeviceInfo!
    
    override func setUpWithError() throws {
        fakeEmarsysClient = FakeGenericNetworkClient()
        sdkContext = SdkContext()
        sdkContext.config = EmarsysConfig()
        sdkContext.config?.applicationCode = "EMS11-C3FD3"
        fakeDeviceInfoCollector = FakeDeviceInfoCollector()
        defaultValues = DefaultValues(version: "testVersion",
                                      clientServiceBaseUrl: "https://base.me-client.eservice.emarsys.net",
                                      eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                      predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                      deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                      inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                      remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        deviceInfo = DeviceInfo(platform: "iOS",
                                applicationVersion: "testVersion",
                                deviceModel: "iPhone14Pro",
                                osVersion: "16.1",
                                sdkVersion: "4.0.0",
                                language: "english",
                                timezone: "testZone",
                                pushSettings: PushSettings(authorizationStatus: "testAuthStatus",
                                                           soundSetting: "testSoundSetting",
                                                           badgeSetting: "testBadgeSetting",
                                                           alertSetting: "testAlertSetting",
                                                           notificationCenterSetting: "testNotificationSetting",
                                                           lockScreenSetting: "testLockScreenSetting",
                                                           carPlaySetting: "testCarPlaySetting",
                                                           alertStyle: "testAlertStyle",
                                                           showPreviewsSetting: "showPreviewSetting",
                                                           criticalAlertSetting: "testCriticalSetting",
                                                           providesAppNotificationSettings: "testProvidesAppNotificationSettings",
                                                           scheduledDeliverySetting: "testScheduledDeliverySetting",
                                                           timeSensitiveSetting: "testTimeSensitiveSetting"))
        defaultDeviceClient = DefaultDeviceClient(emarsysClient: fakeEmarsysClient,
                                                  sdkContext: sdkContext,
                                                  deviceInfoCollector: fakeDeviceInfoCollector,
                                                  defaultValues: defaultValues)
    }
    
    override func tearDownWithError() throws {
        fakeEmarsysClient.tearDown()
        fakeDeviceInfoCollector.tearDown()
    }
    
    func testRegisterClient_shouldThrowError_whenConfigIsNil() async throws {
        sdkContext.config = nil
        
        let expectedError = Errors.preconditionFailed(message: "Config should not be nil!")
        
        await assertThrows(expectedError: expectedError) {
            try await defaultDeviceClient.registerClient()
        }
    }
    
    func testRegisterClient_shouldThrowError_whenApplicationCodeIsNil() async throws {
        sdkContext.config?.applicationCode = nil
        let expectedError = Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        
        await assertThrows(expectedError: expectedError) {
            try await defaultDeviceClient.registerClient()
        }
    }
    
    func testRegisterClient_shouldThrowError_whenUrlCannotBeCreated() async throws {
        let wrongDefaultValues = DefaultValues(version: "testVersion",
                                               clientServiceBaseUrl: "",
                                               eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                               predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                               deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                               inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                               remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        defaultDeviceClient = DefaultDeviceClient(emarsysClient: fakeEmarsysClient,
                                                  sdkContext: sdkContext,
                                                  deviceInfoCollector: fakeDeviceInfoCollector,
                                                  defaultValues: wrongDefaultValues)
        let expectedError = Errors.preconditionFailed(message: "Url cannot be created for registerClientRequest!")
        
        await assertThrows(expectedError: expectedError) {
            try await defaultDeviceClient.registerClient()
        }
    }
    
    func testRegisterClient_shouldSendRequest_withEmarsysClient() async throws {
        let expectation = XCTestExpectation(description: "waitForExpectation")
        fakeDeviceInfoCollector.when(\.collect) { invocationCount, params in
            
            XCTAssertEqual(invocationCount, 1)
            return self.deviceInfo
        }
        
        fakeEmarsysClient.when(\.sendWithBody) { invocationCount, params in
            let request: URLRequest! = try params[0].unwrap()
            let requestBody: DeviceInfo! = try params[1].unwrap()
            
        
            XCTAssertEqual(invocationCount, 1)
            XCTAssertEqual(request.url?.absoluteString, "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client")
            XCTAssertEqual(requestBody, self.deviceInfo)
            
            expectation.fulfill()
            return (Data(), HTTPURLResponse())
        }
        
        try await defaultDeviceClient.registerClient()
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRegisterClient_shouldHandleFailedRequestAndThrow() async throws {
        let failedRequestUrl = URL(string: "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client")
        let response = HTTPURLResponse(url: failedRequestUrl!,
                                       statusCode: 500, httpVersion: "",
                                       headerFields: [String: String]())!
        
        let expectedError = Errors.UserFacingRequestError.registerClientFailed(url: String(describing: failedRequestUrl?.absoluteString))
        let expectation = XCTestExpectation(description: "waitForExpectation")
        fakeDeviceInfoCollector.when(\.collect) { invocationCount, params in
            
            XCTAssertEqual(invocationCount, 1)
            return self.deviceInfo
        }
        
        fakeEmarsysClient.when(\.sendWithBody) { invocationCount, params in
            XCTAssertEqual(invocationCount, 1)
            
            expectation.fulfill()
            throw Errors.NetworkingError.failedRequest(response: response)
        }
        
        await assertThrows(expectedError: expectedError) {
            try await defaultDeviceClient.registerClient()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
