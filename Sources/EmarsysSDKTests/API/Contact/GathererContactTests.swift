//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
final class GathererContactTests: EmarsysTestCase {
    
    let testContactFieldId = 123
    let testOpenIdToken = "testOpenIdToken"
    let testContactFieldValue = "testContactFieldValue"
    
    var contactContext: ContactContext!
    var gathererContact: GathererContact!
    
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
        let contactCalls = PersistentList<ContactCall>(id: "contactCalls", storage: fakeSecureStorage, sdkLogger: sdkLogger)
        contactContext = ContactContext(calls: contactCalls)
        gathererContact = GathererContact(contactContext: contactContext)
    }

    func testLinkContact_shouldAppendCall_onContactContext() async throws {
        let expectedContactCall = ContactCall.linkContact(testContactFieldId, testContactFieldValue)
        
        try await gathererContact.linkContact(contactFieldId: testContactFieldId,
                                              contactFieldValue: testContactFieldValue)
        
        XCTAssertEqual(contactContext.calls.count, 1)
        XCTAssertEqual(expectedContactCall, contactContext.calls.first)
    }
    
    
    func testLinkAuthenticatedContact_shouldAppendCall_onContactContext() async throws {
        let expectedContactCall = ContactCall.linkAuthenticatedContact(testContactFieldId, testOpenIdToken)
        
        try await gathererContact.linkAuthenticatedContact(contactFieldId: testContactFieldId,
                                                           openIdToken: testOpenIdToken)
        
        XCTAssertEqual(contactContext.calls.count, 1)
        XCTAssertEqual(expectedContactCall, contactContext.calls.first)
    }
    
    func testUnlinkContact_shouldAppendCall_onContactContext() async throws {
        let expectedContactCall = ContactCall.unlinkContact
        
        try await gathererContact.unlinkContact()
        
        XCTAssertEqual(contactContext.calls.count, 1)
        XCTAssertEqual(expectedContactCall, contactContext.calls.first)
    }
    
    func testCallOrder() async throws {
        var expectedCalls = PersistentList<ContactCall>(id: "contactCalls", storage: fakeSecureStorage, sdkLogger: sdkLogger)
        expectedCalls.append(ContactCall.linkAuthenticatedContact(testContactFieldId, testOpenIdToken))
        expectedCalls.append(ContactCall.unlinkContact)
        expectedCalls.append(ContactCall.linkContact(testContactFieldId, testContactFieldValue))
        
        try await gathererContact.linkAuthenticatedContact(contactFieldId: testContactFieldId, openIdToken: testOpenIdToken)
        try await gathererContact.unlinkContact()
        try await gathererContact.linkContact(contactFieldId: testContactFieldId, contactFieldValue: testContactFieldValue)
        
        XCTAssertEqual(contactContext.calls.count, 3)
        XCTAssertEqual(expectedCalls, contactContext.calls as! PersistentList<ContactCall>)
    }

}
