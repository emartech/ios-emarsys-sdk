
import XCTest
@testable import EmarsysSDK
import mimic

@SdkActor
final class PredictContactInternalTests: EmarsysTestCase {
    
    var predictContactInternal: PredictContactInternal!
    var contactContext: ContactContext!
    var fakeContactClient: FakeContactClient!
    
    let testFieldId = 123
    let testFieldValue = "testContactFieldValue"
    let testOpenIdToken = "testOpenIdToken"
    
    
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
        fakeContactClient = FakeContactClient()
        predictContactInternal = PredictContactInternal(contactContext: contactContext, contactClient: fakeContactClient)
        fakeContactClient
            .when(\.fnLinkContact)
            .thenReturn(())
        fakeContactClient
            .when(\.fnUnlinkContact)
            .thenReturn(())
    }

    func testLinkContact_shouldDelegateCallToClient() async throws {
        try await predictContactInternal.linkContact(contactFieldId: testFieldId, contactFieldValue: testFieldValue)
        
        _ = try fakeContactClient
            .verify(\.fnLinkContact)
            .wasCalled(Arg.eq(testFieldId), Arg.eq(testFieldValue), Arg.nil)
    }
    
    func testLinkAuthenticatedContact_shouldDelegateCallToClient() async throws {
       try await predictContactInternal.linkAuthenticatedContact(contactFieldId: testFieldId, openIdToken: testOpenIdToken)
        
        _ = try fakeContactClient
            .verify(\.fnLinkContact)
            .wasCalled(Arg.eq(testFieldId), Arg.any, Arg.eq(testOpenIdToken))
    }
    
    func testUnlinkContact_shouldDelegateCallToClient() async throws {
        try await predictContactInternal.unlinkContact()

        _ = try fakeContactClient
            .verify(\.fnUnlinkContact)
            .times(times: .eq(1))
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

        gatheredCalls.forEach { call in
            contactContext.calls.append(call)
        }

        var firstContactFieldId: Int! = 0
        var firstContactFieldValue: String? = nil

        var thirdContactFieldId: Int! = 0
        var thirdOpenIdToken: String? = nil

        fakeContactClient.when(\.fnLinkContact).replaceFunction { invocationCount, params in
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

        try await predictContactInternal.activated()

        XCTAssertEqual(firstContactFieldId, testCallContactId1)
        XCTAssertEqual(firstContactFieldValue, testCallContactFieldValue)

        _ = try fakeContactClient
            .verify(\.fnUnlinkContact)
            .times(times: .eq(1))

        XCTAssertEqual(thirdContactFieldId, testCallContactId2)
        XCTAssertEqual(thirdOpenIdToken, testCallOpenIdToken)
    }
}
