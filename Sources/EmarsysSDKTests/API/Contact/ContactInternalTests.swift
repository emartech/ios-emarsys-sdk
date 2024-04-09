//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import XCTest
@testable import EmarsysSDK
import mimic

@SdkActor
final class ContactInternalTests: EmarsysTestCase {
    
    var contactInternal: ContactInternal!
    var contactContext: ContactContext!
    
    @Inject(\.contactClient)
    var fakeContactClient: FakeContactClient!
    
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
        let contactCalls = try! PersistentList<ContactCall>(id: "contactCalls", storage: fakeSecureStorage, sdkLogger: sdkLogger)
        contactContext = ContactContext(calls: contactCalls)
        contactInternal = ContactInternal(contactContext: contactContext, contactClient: fakeContactClient)
    }
    
    func testLinkContact_shouldDelegateCallToClient() async throws {
        fakeContactClient
            .when(\.fnLinkContact)
            .thenReturn(())
        
        let testFieldId = 123
        let testFieldValue = "testContactFieldValue"
        
        try await contactInternal.linkContact(contactFieldId: testFieldId, contactFieldValue: testFieldValue)
        
        _ = try fakeContactClient
            .verify(\.fnLinkContact)
            .wasCalled(Arg.eq(testFieldId), Arg.eq(testFieldValue), Arg.nil)
    }
    
    func testLinkAuthenticatedContact_shouldDelegateCallToClient() async throws {
        fakeContactClient
            .when(\.fnLinkContact)
            .thenReturn(())
        
        let testFieldId = 123
        let testOpenIdToken = "testOpenIdToken"
        
        try await contactInternal.linkAuthenticatedContact(contactFieldId: testFieldId, openIdToken: testOpenIdToken)
        
        _ = try fakeContactClient
            .verify(\.fnLinkContact)
            .wasCalled(Arg.eq(testFieldId), Arg.nil, Arg.eq(testOpenIdToken))
    }
    
    func testUnlinkContact_shouldDelegateCallToClient() async throws {
        fakeContactClient
            .when(\.fnUnlinkContact)
            .thenReturn(())
        
        try await contactInternal.unlinkContact()
        
        _ = try fakeContactClient
            .verify(\.fnUnlinkContact)
            .times(times: .eq(1))
    }
    
    func testActivated_shouldSendGatheredCallsFirst() async throws {
        fakeContactClient
            .when(\.fnUnlinkContact)
            .thenReturn(())
        
        let testCallContactId1 = 123
        let testCallContactId2 = 456
        let testCallContactFieldValue = "testContactFieldValue"
        let testCallOpenIdToken = "testOpenIdToken"
        
        let call1 = ContactCall.linkContact(testCallContactId1, testCallContactFieldValue)
        let call2 = ContactCall.unlinkContact
        let call3 = ContactCall.linkAuthenticatedContact(testCallContactId2, testCallOpenIdToken)
        
        let gatheredCalls =  [call1, call2, call3]
        
        gatheredCalls.forEach { call in
            contactContext.calls.append(call)
        }
        
        var firstContactFieldId: Int! = 0
        var firstContactFieldValue: String? = nil
        
        var thirdContactFieldId: Int! = 0
        var thirdOpenIdToken: String? = nil
        
        fakeContactClient
            .when(\.fnLinkContact)
            .replaceFunction { invocationCount, params in
            switch invocationCount {
            case 1:
                firstContactFieldId = params[0]
                firstContactFieldValue = params[1]
            case 2:
                thirdContactFieldId = params[0]
                thirdOpenIdToken = params[2]
            default:
                return
            }
            return
        }
        
        try await contactInternal.activated()
        
        XCTAssertEqual(firstContactFieldId, testCallContactId1)
        XCTAssertEqual(firstContactFieldValue, testCallContactFieldValue)
        
        _ = try fakeContactClient
            .verify(\.fnUnlinkContact)
            .times(times: .eq(1))
        
        XCTAssertEqual(thirdContactFieldId, testCallContactId2)
        XCTAssertEqual(thirdOpenIdToken, testCallOpenIdToken)
    }
}
