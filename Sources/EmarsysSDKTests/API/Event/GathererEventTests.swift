//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class GathererEventTests: EmarsysTestCase {
    var gathererEvent: GathererEvent!
    var eventContext: EventContext!
    
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
        let eventCalls = try! PersistentList<EventCall>(id: "eventCalls", storage: fakeSecureStorage, sdkLogger: sdkLogger)
        eventContext = EventContext(calls: eventCalls)
        gathererEvent = GathererEvent(eventContext: eventContext)
    }


    func testTrackCustomEvent_shouldAppendEvent_onEventContext() async throws {
        let eventName = "testName"
        let attributes = ["key1":"value1"]
        let expectedCall = EventCall.trackCustomEvent(eventName, attributes)
        
        try await gathererEvent.trackCustomEvent(name: eventName, attributes: attributes)
        
        XCTAssertEqual(eventContext.calls.count, 1)
        XCTAssertEqual(expectedCall, eventContext.calls.first)
    }


    func testCallOrder() async throws {
        let eventName = "testName"
        let attributes = ["key1":"value1"]
        let eventName2 = "testName2"
        let attributes2 = ["key2":"value2"]
        let eventName3 = "testName3"
        let attributes3 = ["key3":"value3"]
        
        let expectedCalls = try PersistentList<EventCall>(id: "eventCalls", storage: fakeSecureStorage, elements: [
            EventCall.trackCustomEvent(eventName, attributes),
            EventCall.trackCustomEvent(eventName2, attributes2),
            EventCall.trackCustomEvent(eventName3, attributes3)
        ], sdkLogger: sdkLogger)

        try await gathererEvent.trackCustomEvent(name: eventName, attributes: attributes)
        try await gathererEvent.trackCustomEvent(name: eventName2, attributes: attributes2)
        try await gathererEvent.trackCustomEvent(name: eventName3, attributes: attributes3)

        XCTAssertEqual(eventContext.calls.count, 3)
        XCTAssertEqual(expectedCalls, eventContext.calls)
    }
}
