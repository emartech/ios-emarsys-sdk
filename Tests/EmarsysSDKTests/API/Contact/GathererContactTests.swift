//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
final class GathererContactTests: XCTestCase {
    
    let testContactFieldId = 123
    let testOpenIdToken = "testOpenIdToken"
    let testContactFieldValue = "testContactFieldValue"
    
    var contactContext: ContactContext!
    var gathererContact: GathererContact!

    override func setUpWithError() throws {
        contactContext = ContactContext()
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
        let expectedCalls = [
            ContactCall.linkAuthenticatedContact(testContactFieldId, testOpenIdToken),
            ContactCall.unlinkContact,
            ContactCall.linkContact(testContactFieldId, testContactFieldValue)
        ]
        
        try await gathererContact.linkAuthenticatedContact(contactFieldId: testContactFieldId, openIdToken: testOpenIdToken)
        try await gathererContact.unlinkContact()
        try await gathererContact.linkContact(contactFieldId: testContactFieldId, contactFieldValue: testContactFieldValue)
        
        XCTAssertEqual(contactContext.calls.count, 3)
        XCTAssertEqual(expectedCalls, contactContext.calls)
    }

}
