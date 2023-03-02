//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import XCTest
@testable import EmarsysSDK

@SdkActor
final class ContactInternalTests: EmarsysTestCase {
    
    var contactInternal: ContactInternal!
    var contactContext: ContactContext!
    
    @Inject(\.contactClient)
    var fakeContactClient: FakeContactClient!
    
    override func setUpWithError() throws {
        contactContext = ContactContext()
        fakeContactClient = FakeContactClient()
        contactInternal = ContactInternal(contactContext: contactContext, contactClient: fakeContactClient)
    }
    
    func testLinkContact_shouldDelegateCallToClient() async throws {
        let testFieldId = 123
        let testFieldValue = "testContactFieldValue"
        
        var contactFieldId: Int? = nil
        var contactFieldValue: String? = nil
        
        fakeContactClient.when(\.linkContact) { invocationCount, params in
            contactFieldId = try params[0].unwrap()
            contactFieldValue = try params[1].unwrap()
            return
        }
        
        try await contactInternal.linkContact(contactFieldId: testFieldId, contactFieldValue: testFieldValue)
        
        XCTAssertEqual(contactFieldId, testFieldId)
        XCTAssertEqual(contactFieldValue, testFieldValue)
    }
    
    func testLinkAuthenticatedContact_shouldDelegateCallToClient() async throws {
        let testFieldId = 123
        let testOpenIdToken = "testOpenIdToken"
        
        var contactFieldId: Int? = nil
        var openId: String? = nil
        
        fakeContactClient.when(\.linkContact) { invocationCount, params in
            contactFieldId = try params[0].unwrap()
            openId =  try params[2].unwrap()
            
            return
        }
        
        try await contactInternal.linkAuthenticatedContact(contactFieldId: testFieldId, openIdToken: testOpenIdToken)
        
        XCTAssertEqual(contactFieldId, testFieldId)
        XCTAssertEqual(openId, testOpenIdToken)
    }
    
    func testUnlinkContact_shouldDelegateCallToClient() async throws {
        
        var callCounter: Int = 0
        
        fakeContactClient.when(\.unlinkContact) { invocationCount, params in
            callCounter = invocationCount
            return
        }
        
        try await contactInternal.unlinkContact()
        
        XCTAssertEqual(callCounter, 1)
    }

    func testActivated_shouldSendGatheredCallsFirst() async throws {
        let testCallContactId1 = 123
        let testCallContactId2 = 456
        let testCallContactFieldValue = "testContactFieldValue"
        let testCallOpenIdToken = "testOpenIdToken"

        let call1 = ContactCall.linkContact(testCallContactId1, testCallContactFieldValue)
        let call2 = ContactCall.unlinkContact
        let call3 = ContactCall.linkAuthenticatedContact(testCallContactId2, testCallOpenIdToken)

        let gatheredCalls =  [call1, call2, call3]

        contactContext.calls = gatheredCalls

        var firstContactFieldId: Int! = 0
        var firstContactFieldValue: String? = nil

        var secondCallCounter: Int = 0

        var thirdContactFieldId: Int! = 0
        var thirdOpenIdToken: String? = nil

        fakeContactClient.when(\.linkContact) { invocationCount, params in
            switch invocationCount {
            case 1:
                firstContactFieldId = try params[0].unwrap()
                firstContactFieldValue = try params[1].unwrap()
            case 2:
                thirdContactFieldId = try params[0].unwrap()
                thirdOpenIdToken = try params[2].unwrap()
            default:
                return
            }
            return
        }

        fakeContactClient.when(\.unlinkContact) { invocationCount, params in
            secondCallCounter = invocationCount
            return
        }

        try await contactInternal.activated()

        XCTAssertEqual(firstContactFieldId, testCallContactId1)
        XCTAssertEqual(firstContactFieldValue, testCallContactFieldValue)

        XCTAssertEqual(secondCallCounter, 1)

        XCTAssertEqual(thirdContactFieldId, testCallContactId2)
        XCTAssertEqual(thirdOpenIdToken, testCallOpenIdToken)
    }
}
