//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

class EventTests: EmarsysTestCase {
    
    var event: Events<LoggingEvent, GathererEvent, FakeEventApi>!
    var loggingEvent: EventInstance!
    var gathererEvent: EventInstance!
    var fakeEventInternal: EventInstance!
    var eventContext: EventContext!
    var timestampProvider: TimestampProvider!
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
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
        timestampProvider = TimestampProvider()
        fakeEventInternal = FakeEventApi()
        gathererEvent = GathererEvent(eventContext: eventContext)
        loggingEvent = LoggingEvent(logger: sdkLogger)
        
        event = Events(loggingInstance: loggingEvent as! LoggingEvent,
                      gathererInstance: gathererEvent as! GathererEvent,
                      internalInstance: fakeEventInternal as! FakeEventApi,
                      sdkContext: sdkContext)
    }

    func testInit_shouldInitEvent_withLoggingEventAsActive() {

        XCTAssertTrue(event.active is LoggingEvent)
    }
    
    func testActiveEvent_shouldBeSet_basedOnSdkState() {
        sdkContext.setSdkState(sdkState: .onHold)
      
        XCTAssertTrue(event.active is GathererEvent)
        
        sdkContext.setSdkState(sdkState: .inactive)
        
        XCTAssertTrue(event.active is LoggingEvent)
    }
    
    func testActiveEvent_shouldChangeActiveInstance_basedOnSdkStateAndFeatures() {
        sdkContext.setSdkState(sdkState: .active)
        
        XCTAssertTrue(event.active is LoggingEvent)
        
        sdkContext.setFeatures(features: [Feature.mobileEngage])
        
        XCTAssertTrue(event.active is FakeEventApi)
        
        sdkContext.setFeatures(features: [])
        
        XCTAssertTrue(event.active is LoggingEvent)
    }
}
