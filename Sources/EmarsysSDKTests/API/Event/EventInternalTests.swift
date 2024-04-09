//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK
import mimic

@SdkActor
final class EventInternalTests: EmarsysTestCase {
    
    var eventInternal: EventInternal!
    var eventContext: EventContext!
    var timeStampProvider: TimestampProvider!
    
    @Inject(\.eventClient)
    var fakeEventClient: FakeEventClient!
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage!
    
    @Inject(\.sdkLogger)
    var sdkLogger: SdkLogger!
    
    override func setUpWithError() throws {
        fakeSecureStorage
            .when(\.fnGet)
            .thenReturn(nil)
        fakeSecureStorage
            .when(\.fnPut)
            .thenReturn(())
        let calls = try! PersistentList<EventCall>(id: "eventCalls", storage: self.fakeSecureStorage, sdkLogger: self.sdkLogger)
        eventContext = EventContext(calls: calls)
        
        timeStampProvider = TimestampProvider()
        eventInternal = EventInternal(eventContext: eventContext, eventClient: fakeEventClient, timestampProvider: timeStampProvider)
    }

    func testTrackCustomEvent_shouldDelegateCallToEventClient() async throws {
        let eventName = "testName"
        let eventAttributes = ["key1":"value1"]

        fakeEventClient
            .when(\.fnSendEvents)
            .thenReturn(EventResponse(message: nil, onEventAction: nil, deviceEventState: nil))

        try await eventInternal.trackCustomEvent(name: eventName, attributes: eventAttributes)
        
        _ = try fakeEventClient
            .verify(\.fnSendEvents)
            .wasCalled(Arg.eq(eventName), Arg.eq(eventAttributes), Arg.eq(EventType.customEvent))
            .times(times: .eq(1))
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

        gatheredCalls.forEach { call in
            eventContext.calls.append(call)
        }

        var name: String? = nil
        var attributes: [String:String]? = nil
        var name2: String? = nil
        var attributes2: [String:String]? = nil
        var name3: String? = nil
        var attributes3: [String:String]? = nil

        fakeEventClient.when(\.fnSendEvents).replaceFunction { invocationCount, params in
            switch invocationCount {
            case 1:
                name = params[0]
                attributes = params[1]
            case 2:
                name2 = params[0]
                attributes2 = params[1]
            case 3:
                name3 = params[0]
                attributes3 = params[1]
            default:
                return EventResponse(message: nil, onEventAction: nil, deviceEventState: nil)
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
