//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class EventTests: EmarsysTestCase {
    
    var event: Event!
    var loggingEvent: ActivatableEventApi!
    var gathererEvent: ActivatableEventApi!
    var fakeEventInternal: ActivatableEventApi!
    var eventContext: EventContext!
    var timestampProvider: TimestampProvider!
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.sdkLogger)
    var sdkLogger:SdkLogger

    override func setUpWithError() throws {
        timestampProvider = TimestampProvider()
        eventContext = EventContext()
        fakeEventInternal = FakeEventApi()
        gathererEvent = GathererEvent(eventContext: eventContext)
        loggingEvent = LoggingEvent(logger: sdkLogger)
        
        event = Event(sdkContext: sdkContext, eventInternal: fakeEventInternal, loggingEvent: loggingEvent, gathererEvent: gathererEvent)
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