import XCTest
@testable import EmarsysSDK

@SdkActor
final class ContactTests: XCTestCase {
    
    var fakePredictContactApi: FakePredictContactApi!
    
    var loggingContact: ActivatableContactApi!
    
    var gatherer: ActivatableContactApi!

    var contactContext: ContactContext!
    
    var contact: Contact!
    
    @Inject(\.contactApi)
    var fakeContactApi: FakeContactApi
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.sdkLogger)
    var sdkLogger:SdkLogger
    
    override func setUp() async throws {
        fakePredictContactApi = FakePredictContactApi()
        contactContext = ContactContext()
        loggingContact = LoggingContact(logger: sdkLogger)
        gatherer = GathererContact(contactContext: contactContext)

        contact = Contact(loggingContact: loggingContact,
                          gathererContact: gatherer,
                          contactInternal: fakeContactApi,
                          predictContactInternal: fakePredictContactApi,
                          sdkContext: sdkContext)
    }

    func testInit_shouldInitContact_withLoggingContactAsActive() {
        let testContact = Contact(
            loggingContact: loggingContact,
            gathererContact: gatherer,
            contactInternal: fakeContactApi,
            predictContactInternal: fakePredictContactApi,
            sdkContext: sdkContext
        )

        XCTAssertTrue(testContact.active is LoggingContact)
    }
    
    func testActiveContact_shouldBeSet_basedOnSdkState() {
        sdkContext.setSdkState(sdkState: .onHold)
      
        XCTAssertTrue(contact.active is GathererContact)
        
        sdkContext.setSdkState(sdkState: .inactive)
        
        XCTAssertTrue(contact.active is LoggingContact)
    }
    
    func testActiveContact_shouldBePredictContact() {
        sdkContext.setFeatures(features: [.predict])
        sdkContext.setSdkState(sdkState: .active)
      
        XCTAssertEqual(contact.active as? FakePredictContactApi, fakePredictContactApi)
    }
    
    func testActiveContact_shouldBeContactInternal_whenActiveFeaturesAreMobileEngageAndPredict() {
        sdkContext.setFeatures(features: [.mobileEngage, .predict])
        sdkContext.setSdkState(sdkState: .active)
      
        XCTAssertEqual(contact.active as? FakeContactApi, fakeContactApi)
    }
    
    func testActiveContact_shouldBeContactInternal_whenActiveFeatureIsMobileEngageOnly() {
        sdkContext.setFeatures(features: [.mobileEngage])
        sdkContext.setSdkState(sdkState: .active)
        
        XCTAssertEqual(contact.active as? FakeContactApi, fakeContactApi)
    }
    
    func testLinkContact_shouldCallLinkContact_onActiveInstance() async throws {
        sdkContext.setFeatures(features: [.mobileEngage])
        sdkContext.setSdkState(sdkState: .active)
        
        let contactFieldId = 123
        let contactFieldValue = "testContactFieldValue"
        
        fakeContactApi.when(\.linkContact) { invocationCount, params in
            let receivedContactFieldId: Int! = try params[0].unwrap()
            let receivedContactFieldValue: String! = try params[1].unwrap()
            
            XCTAssertEqual(receivedContactFieldId, contactFieldId)
            XCTAssertEqual(receivedContactFieldValue, contactFieldValue)
            
            return ()
        }
        
        try await contact.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue)
    }
    
    
    func testLinkContact_shouldCallLinkAuthenticatedContact_onActiveInstance() async throws {
        sdkContext.setFeatures(features: [.mobileEngage])
        sdkContext.setSdkState(sdkState: .active)
        
        let contactFieldId = 123
        let openIdToken = "testOpenIdToken"
        
        fakeContactApi.when(\.linkAuthenticatedContact) { invocationCount, params in
            let receivedContactFieldId: Int! = try params[0].unwrap()
            let receivedOpenIdToken: String! = try params[1].unwrap()
            
            XCTAssertEqual(receivedContactFieldId, contactFieldId)
            XCTAssertEqual(receivedOpenIdToken, openIdToken)
            
            return ()
        }
        
        try await contact.linkAuthenticatedContact(contactFieldId: contactFieldId, openIdToken: openIdToken)
    }
    
    func testLinkContact_shouldCallUnlinkContact_onActiveInstance() async throws {
        sdkContext.setFeatures(features: [.mobileEngage])
        sdkContext.setSdkState(sdkState: .active)

        let expectation = XCTestExpectation(description: "waitForInvocation")
        
        fakeContactApi.when(\.unlinkContact) { invocationCount, params in
            expectation.fulfill()
            
            return ()
        }
        
        try await contact.unlinkContact()
        
        wait(for: [expectation], timeout: 2)
    }
    
}
