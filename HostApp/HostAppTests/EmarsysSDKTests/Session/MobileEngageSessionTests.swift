//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//


import XCTest
import mimic
@testable import EmarsysSDK

@SdkActor
final class MobileEngageSessionTests: EmarsysTestCase {
    let testUuid = "testUuid"
    var testDate: Date!
    var testEndDate: Date!
    
    @Inject(\.sessionContext)
    var sessionContext: SessionContext
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.timestampProvider)
    var fakeTimestampProvider: FakeTimestampProvider
    
    @Inject(\.uuidProvider)
    var fakeUuidProvider: FakeUuidProvider
    
    @Inject(\.eventClient)
    var fakeEventClient: FakeEventClient
    
    @Inject(\.deviceInfoCollector)
    var fakeDeviceInfoCollector: FakeDeviceInfoCollector
    
    @Inject(\.sdkLogger)
    var logger: SdkLogger
    
    var session: MobileEngageSession!
    
    
    override func setUpWithError() throws {
        testDate = Date()
        testEndDate = testDate.addingTimeInterval(TimeInterval(300))
        
        fakeEventClient.when(\.fnSendEvents).thenReturn(EventResponse(message: nil, onEventAction: nil, deviceEventState: nil))
        fakeUuidProvider.when(\.fnProvide).thenReturn(testUuid)
        fakeTimestampProvider.when(\.fnProvide).thenReturn(testDate)
        
        self.sessionContext.contactToken = "testContactToken"
        let testConfig = EmarsysConfig(applicationCode: "testApplicationCode")
        self.sdkContext.config = testConfig
        
        self.session = MobileEngageSession(sessionContext: self.sessionContext,
                                           sdkContext: self.sdkContext,
                                           timestampProvider: self.fakeTimestampProvider,
                                           uuidProvider: self.fakeUuidProvider,
                                           eventClient: self.fakeEventClient,
                                           logger: self.logger)
    }
    
    func testStart_shouldSendInternalCustomEvent() async throws {
        
        await self.session.start()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).wasCalled(Arg.eq("session:start"), Arg.nil, Arg.eq(EventType.internalEvent))
    }
    
    func testStart_should_reset_when_eventClient_throws() async throws {
        let error = Errors.NetworkingError.failedRequest(response: HTTPURLResponse())
        fakeEventClient.when(\.fnSendEvents).thenThrow(error: error)
        
        await self.session.start()
        
        XCTAssertNil(self.sessionContext.sessionId)
        XCTAssertNil(self.session.sessionStartTime)
    }
    
    func testStart_shouldNotSendEvent_whenApplicationCode_isNil() async throws {
        let testConfig = EmarsysConfig()
        self.sdkContext.config = testConfig
        
        await self.session.start()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).times(times: .eq(0))
    }
    
    func testStart_shouldNotSendEvent_contactToken_isNil() async throws {
        self.sessionContext.contactToken = nil
        
        await self.session.start()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).times(times: .eq(0))
    }
    
    func testStart_shouldSet_sessionId_onSessionContext() async {
        await self.session.start()
        
        XCTAssertEqual(self.sessionContext.sessionId, testUuid)
    }
    
    func testStart_shouldSet_sessionStartTime() async {
        await self.session.start()
        
        XCTAssertEqual(self.session.sessionStartTime, self.testDate)
    }
    
    func testStop_shouldSendInternalCustomEvent_andResetSessionId() async throws {
        self.session.sessionStartTime = testDate
        self.sessionContext.sessionId = testUuid
        let expectedAttribute = ["duration":"300000"]
        
        fakeTimestampProvider.when(\.fnProvide).thenReturn(testEndDate)
        
        await self.session.stop()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).wasCalled(Arg.eq("session:stop"), Arg.eq(expectedAttribute), Arg.eq(EventType.internalEvent))
        XCTAssertNil(self.sessionContext.sessionId)
    }
    
    func testStop_shouldNotSendInternalCustomEvent_whenSessionWasNotStartedBefore() async throws {
        self.session.sessionStartTime = nil
        
        fakeTimestampProvider.when(\.fnProvide).thenReturn(testEndDate)
        
        await self.session.stop()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).times(times: .zero)
    }
    
    func testStop_shouldNotSendInternalCustomEvent_whenSessionId_isMissing() async throws {
        self.session.sessionStartTime = testDate
        sessionContext.sessionId = nil
        
        fakeTimestampProvider.when(\.fnProvide).thenReturn(testEndDate)
        
        await self.session.stop()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).times(times: .zero)
    }
    
    func testStop_should_reset_when_eventClient_throws() async throws {
        self.session.sessionStartTime = testDate
        self.sessionContext.sessionId = testUuid
        let error = Errors.NetworkingError.failedRequest(response: HTTPURLResponse())
        fakeEventClient.when(\.fnSendEvents).thenThrow(error: error)
        
        await self.session.stop()
        
        XCTAssertNil(self.sessionContext.sessionId)
        XCTAssertNil(self.session.sessionStartTime)
    }
}
