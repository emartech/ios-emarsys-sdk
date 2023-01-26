import XCTest
@testable import EmarsysSDK

@SdkActor
final class ContactTests: XCTestCase {
    var loggingContact: ContactApi!
    var internalContact: ContactApi!
    var gatherer: ContactApi!
    var sdkContext: SdkContext!
    var contactContext: ContactContext!
    var fakeContactClient: ContactClient!

    override func setUp() async throws {
        contactContext = ContactContext()
        fakeContactClient = FakeContactClient()
        loggingContact = LoggingContact()
        internalContact = ContactInternal(contactContext: contactContext, contactClient: fakeContactClient)
        gatherer = GathererContact(contactContext: contactContext)
        sdkContext = SdkContext()
    }
    
    override func tearDown() {
        DependencyInjection.tearDown()
    }

    func testInit_shouldInitContact_withLoggingContactAsActive() {
        let testContact = Contact(
            loggingContact: loggingContact,
            gathererContact: gatherer,
            contactInternal: internalContact,
            sdkContext: sdkContext
        )

        XCTAssertTrue(testContact.active is LoggingContact)
    }
}
