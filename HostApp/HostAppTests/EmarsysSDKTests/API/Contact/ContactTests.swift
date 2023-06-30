import XCTest
import mimic
@testable import EmarsysSDK

@SdkActor
final class ContactTests: EmarsysTestCase {
    
    var fakePredictContactApi: FakePredictContactApi!
    
    var loggingContact: ContactInstance!
    
    var gatherer: ContactInstance!
    
    var contactContext: ContactContext!
    
    var contact: Contact<LoggingContact, GathererContact, FakeContactApi>!
    
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
        
        contact = Contact(loggingInstance: loggingContact as! LoggingContact,
                          gathererInstance: gatherer as! GathererContact,
                          internalInstance: fakeContactApi,
                          predictContactInternal: fakePredictContactApi,
                          sdkContext: sdkContext)
    }
    
    func testInit_shouldInitContact_withLoggingContactAsActive() {
        XCTAssertTrue(contact.active is LoggingContact)
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
        fakeContactApi
            .when(\.fnLinkContact)
            .thenReturn(())
        
        sdkContext.setFeatures(features: [.mobileEngage])
        sdkContext.setSdkState(sdkState: .active)
        
        let contactFieldId = 123
        let contactFieldValue = "testContactFieldValue"
        
        try await contact.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue)
        
        _ = try fakeContactApi
            .verify(\.fnLinkContact)
            .wasCalled(Arg.eq(contactFieldId), Arg.eq(contactFieldValue))
    }
    
    func testLinkContact_shouldCallLinkAuthenticatedContact_onActiveInstance() async throws {
        fakeContactApi
            .when(\.fnLinkAuthenticatedContact)
            .thenReturn(())
        
        sdkContext.setFeatures(features: [.mobileEngage])
        sdkContext.setSdkState(sdkState: .active)
        
        let contactFieldId = 123
        let openIdToken = "testOpenIdToken"
        
        try await contact.linkAuthenticatedContact(contactFieldId: contactFieldId, openIdToken: openIdToken)
        
        _ = try fakeContactApi
            .verify(\.fnLinkAuthenticatedContact)
            .wasCalled(Arg.eq(contactFieldId), Arg.eq(openIdToken))
        
    }
    
    func testLinkContact_shouldCallUnlinkContact_onActiveInstance() async throws {
        fakeContactApi
            .when(\.fnUnlinkContact)
            .thenReturn(())
        
        sdkContext.setFeatures(features: [.mobileEngage])
        sdkContext.setSdkState(sdkState: .active)
        
        try await contact.unlinkContact()
        
        _ = try fakeContactApi
            .verify(\.fnUnlinkContact)
            .times(times: .eq(1))
    }
    
}
