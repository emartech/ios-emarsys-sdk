//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class EventInternalTests: EmarsysTestCase {
    
    var eventInternal: EventInternal!
    var eventContext: EventContext!
    var timeStampProvider: TimestampProvider!
    
    @Inject(\.eventClient)
    var fakeEventClient: FakeEventClient!

    override func setUpWithError() throws {
        eventContext = EventContext()
        timeStampProvider = TimestampProvider()
        eventInternal = EventInternal(eventContext: eventContext, eventClient: fakeEventClient, timestampProvider: timeStampProvider)
    }

    func testTrackCustomEvent_shouldDelegateCallToEventClient() async throws {
        let eventName = "testName"
        let eventAttributes = ["key1":"value1"]
        
        var invocationCounter: Int = 0
        var name: String? = nil
        var attributes: [String:String]? = nil
        
        fakeEventClient.when(\.sendEvents) { invocationCount, params in
            invocationCounter = invocationCount
            name = try params[0].unwrap()
            attributes = try params[1].unwrap()
            return EventResponse(message: nil, onEventAction: nil, deviceEventState: nil)
        }
        
        try await eventInternal.trackCustomEvent(name: eventName, attributes: eventAttributes)
        
        XCTAssertEqual(invocationCounter, 1)
        XCTAssertEqual(name, eventName)
        XCTAssertEqual(attributes, eventAttributes)
    }

    func testActivated_shouldSendGatheredCallsFirst() async throws {
        let eventName = "testName"
        let eventAttributes = ["key1":"value1"]
        let eventName2 = "testName2"
        let eventAttributes2 = ["key2":"value2"]
        let eventName3 = "testName3"
        let eventAttributes3 = ["key3":"value3"]
        let gatheredCalls = [
            EventCall.trackCustomEvent(eventName, eventAttributes),
            EventCall.trackCustomEvent(eventName2, eventAttributes2),
            EventCall.trackCustomEvent(eventName3, eventAttributes3)
        ]

        eventContext.calls = gatheredCalls

        var name: String? = nil
        var attributes: [String:String]? = nil
        var name2: String? = nil
        var attributes2: [String:String]? = nil
        var name3: String? = nil
        var attributes3: [String:String]? = nil

        fakeEventClient.when(\.sendEvents) { invocationCount, params in
            switch invocationCount {
            case 1:
                name = try params[0].unwrap()
                attributes = try params[1].unwrap()
            case 2:
                name2 = try params[0].unwrap()
                attributes2 = try params[1].unwrap()
            case 3:
                name3 = try params[0].unwrap()
                attributes3 = try params[1].unwrap()
            default:
                return
            }
            return EventResponse(message: nil, onEventAction: nil, deviceEventState: nil)
        }

        try await eventInternal.activated()

        XCTAssertEqual(name, eventName)
        XCTAssertEqual(attributes, eventAttributes)
        XCTAssertEqual(name2, eventName2)
        XCTAssertEqual(attributes2, eventAttributes2)
        XCTAssertEqual(name3, eventName3)
        XCTAssertEqual(attributes3, eventAttributes3)
    }

}
