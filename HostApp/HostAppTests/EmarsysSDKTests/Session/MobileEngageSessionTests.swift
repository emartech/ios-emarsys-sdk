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
    let testDate = Date()
    
    @Inject(\.sessionContext)
    var fakeSessionContext: SessionContext
    
    @Inject(\.sdkContext)
    var fakeSdkContext: SdkContext
    
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
        fakeEventClient.when(\.fnSendEvents).thenReturn(EventResponse(message: nil, onEventAction: nil, deviceEventState: nil))
        fakeUuidProvider.when(\.fnProvide).thenReturn(testUuid)
        fakeTimestampProvider.when(\.fnProvide).thenReturn(testDate)
        
        self.fakeSessionContext.contactToken = "testContactToken"
        let testConfig = EmarsysConfig(applicationCode: "testApplicationCode")
        self.fakeSdkContext.config = testConfig
        
        self.session = MobileEngageSession(sessionContext: self.fakeSessionContext,
                                           sdkContext: self.fakeSdkContext,
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
        
        XCTAssertNil(self.fakeSessionContext.sessionId)
        XCTAssertNil(self.session.sessionStartTime)
    }
    
    func testStart_shouldNotSendEvent_whenApplicationCode_isNil() async throws {
        let testConfig = EmarsysConfig()
        self.fakeSdkContext.config = testConfig
        
        await self.session.start()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).times(times: .eq(0))
    }
    
    func testStart_shouldNotSendEvent_contactToken_isNil() async throws {
        self.fakeSessionContext.contactToken = nil
        
        await self.session.start()
        
        _ = try fakeEventClient.verify(\.fnSendEvents).times(times: .eq(0))
    }
    
    func testStart_shouldSet_sessionId_onSessionContext() async {
        await self.session.start()
        
        XCTAssertEqual(self.fakeSessionContext.sessionId, testUuid)
    }
    
    func testStart_shouldSet_sessionStartTime() async {
        await self.session.start()
        
        XCTAssertEqual(self.session.sessionStartTime, self.testDate)
    }
    
}
