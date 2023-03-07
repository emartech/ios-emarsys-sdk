//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class DefaultEventClientTests: EmarsysTestCase {
    var defaultEventClient: EventClient!

    @Inject(\.genericNetworkClient)
    var fakeNetworkClient: FakeGenericNetworkClient

    @Inject(\.sessionContext)
    var sessionContext: SessionContext

    @Inject(\.timestampProvider)
    var fakeTimeStampProvider: FakeTimestampProvider!

    @Inject(\.sdkContext)
    var sdkContext: SdkContext

    override func setUpWithError() throws {
        fakeTimeStampProvider.when(\.provideFuncName) { invocationCount, params in
            return Date()
        }

        defaultEventClient = DefaultEventClient(networkClient: fakeNetworkClient,
                sdkContext: sdkContext,
                sessionContext: sessionContext,
                timestampProvider: fakeTimeStampProvider)
    }

    func testSendEvents_shouldDelegateCallToEventClient_andSetDeviceEventStateOnSessionContext() async throws {
        let eventName = "testName"
        let testCampaignId = "testCampaignId"

        let eventAttributes = ["key1": "value1"]
        let testMessage = ["message": "content"]
        let testDeviceEventState = Data(count: 10)
        let testOnEventAction = OnEventActionResponse(campaignId: testCampaignId, actions: [GenericAction]())

        let expectedResponse = EventResponse(message: testMessage,
                onEventAction: testOnEventAction,
                deviceEventState: testDeviceEventState)

        var name: String? = nil
        var attributes: [String: String]? = nil

        fakeNetworkClient.when(\.sendWithBody) { invocationCount, params in
            let body: EventRequest! = try params[1].unwrap()
            name = body.events.first?.name
            attributes = body.events.first?.attributes
            return (expectedResponse, HTTPURLResponse())
        }

        let result = try await defaultEventClient.sendEvents(name: eventName, attributes: eventAttributes)

        XCTAssertEqual(name, eventName)
        XCTAssertEqual(attributes, eventAttributes)
        XCTAssertEqual(result.message, testMessage)
        XCTAssertEqual(result.onEventAction?.campaignId, testCampaignId)
        XCTAssertEqual(result.deviceEventState, testDeviceEventState)

        XCTAssertEqual(sessionContext.deviceEventState, testDeviceEventState)
    }
}
