//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class DefaultDeviceClientTests: XCTestCase {

    @Inject(\.deviceInfoCollector)
    var fakeDeviceInfoCollector: FakeDeviceInfoCollector

    @Inject(\.genericNetworkClient)
    var fakeNetworkClient: FakeGenericNetworkClient

    @Inject(\.sdkContext)
    var sdkContext: SdkContext

    let deviceInfo = DeviceInfo(platform: "iOS",
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
                    timeSensitiveSetting: "testTimeSensitiveSetting"),
            hardwareId: "testHardwareId")

    var defaultDeviceClient: DeviceClient!

    override func setUpWithError() throws {
        defaultDeviceClient = DefaultDeviceClient(emarsysClient: fakeNetworkClient,
                sdkContext: sdkContext,
                deviceInfoCollector: fakeDeviceInfoCollector)
    }

    func testRegisterClient_shouldSendRequest_withEmarsysClient() async throws {
        let expectation = XCTestExpectation(description: "waitForExpectation")
        fakeDeviceInfoCollector.when(\.collect) { invocationCount, params in

            XCTAssertEqual(invocationCount, 1)
            return self.deviceInfo
        }

        fakeNetworkClient.when(\.sendWithBody) { invocationCount, params in
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

        fakeNetworkClient.when(\.sendWithBody) { invocationCount, params in
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
