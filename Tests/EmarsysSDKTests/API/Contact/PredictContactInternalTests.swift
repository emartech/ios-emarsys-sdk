
import XCTest
@testable import EmarsysSDK

@SdkActor
final class PredictContactInternalTests: XCTestCase {
    
    var predictContactInternal: PredictContactInternal!
    var contactContext: ContactContext!
    var fakeContactClient: FakeContactClient!
    
    let testFieldId = 123
    let testFieldValue = "testContactFieldValue"
    let testOpenIdToken = "testOpenIdToken"
    
    override func setUpWithError() throws {
        contactContext = ContactContext()
        fakeContactClient = FakeContactClient()
        predictContactInternal = PredictContactInternal(contactContext: contactContext, contactClient: fakeContactClient)
    }
    
    override func tearDownWithError() throws {
        tearDownFakes()
    }
    
    func testLinkContact_shouldDelegateCallToClient() async throws {
        
        var contactFieldId: Int? = nil
        var contactFieldValue: String? = nil
        
        fakeContactClient.when(\.linkContact) { invocationCount, params in
            contactFieldId = try params[0].unwrap()
            contactFieldValue = try params[1].unwrap()
            return
        }
        
        try await predictContactInternal.linkContact(contactFieldId: testFieldId, contactFieldValue: testFieldValue)
        
        XCTAssertEqual(contactFieldId, testFieldId)
        XCTAssertEqual(contactFieldValue, testFieldValue)
    }
    
    func testLinkAuthenticatedContact_shouldDelegateCallToClient() async throws {
        
        var contactFieldId: Int? = nil
        var openId: String? = nil
        
        fakeContactClient.when(\.linkContact) { invocationCount, params in
            contactFieldId = try params[0].unwrap()
            openId =  try params[2].unwrap()
            
            return
        }
        
        try await predictContactInternal.linkAuthenticatedContact(contactFieldId: testFieldId, openIdToken: testOpenIdToken)
        
        XCTAssertEqual(contactFieldId, testFieldId)
        XCTAssertEqual(openId, testOpenIdToken)
    }
    
    func testUnlinkContact_shouldDelegateCallToClient() async throws {
        
        var callCounter: Int = 0
        
        fakeContactClient.when(\.unlinkContact) { invocationCount, params in
            callCounter = invocationCount
            return
        }
        
        try await predictContactInternal.unlinkContact()

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

        try await predictContactInternal.activated()

        XCTAssertEqual(firstContactFieldId, testCallContactId1)
        XCTAssertEqual(firstContactFieldValue, testCallContactFieldValue)

        XCTAssertEqual(secondCallCounter, 1)

        XCTAssertEqual(thirdContactFieldId, testCallContactId2)
        XCTAssertEqual(thirdOpenIdToken, testCallOpenIdToken)
    }
}
