//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

final class LinkContactStateTests: EmarsysTestCase {
    
    @Inject(\.contactClient)
    var fakeContactClient: FakeContactClient
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage
    
    var linkContactState: LinkContactState!

    override func setUpWithError() throws {
        linkContactState = LinkContactState(contactClient: fakeContactClient, secureStorage: fakeSecureStorage)
    }

    func testActive_whenContactTokenIsNotNil() async throws {
        fakeSecureStorage.when(\.get) { invocationCount, params in
            return "testContactToken"
        }
        
        var contactClientWasCalled = false
        let expectation = XCTestExpectation(description: "waitForContactClient")
        fakeContactClient.when(\.linkContact) { invocationCount, params in
            contactClientWasCalled = true
            expectation.fulfill()
            return
        }
        fakeContactClient.when(\.unlinkContact) { invocationCount, params in
            contactClientWasCalled = true
            expectation.fulfill()
            return
        }
        
        try await linkContactState.active()
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(waiterResult, .timedOut)
        XCTAssertFalse(contactClientWasCalled)
    }
    
    func testActive_whenContactCredentialsAreNil() async throws {
        fakeSecureStorage.when(\.get) { invocationCount, params in
            return nil
        }
        
        var unlinkContactWasCalled = false
        let expectation = XCTestExpectation(description: "waitForContactClient")
        fakeContactClient.when(\.unlinkContact) { invocationCount, params in
            unlinkContactWasCalled = true
            expectation.fulfill()
            return
        }
        
        try await linkContactState.active()
        
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(unlinkContactWasCalled)
    }

    func testActive_whenContactFieldIdAndContactFieldValueIsNotNil() async throws {
        fakeSecureStorage.when(\.get) { invocationCount, params in
            let key: String! = try params[0].unwrap()
            var result: Any?
            switch key {
            case Constants.Contact.contactFieldId:
                result = 123
            case Constants.Contact.contactFieldValue:
                result = "testContactFieldValue"
            default:
                result = nil
            }
            return result
        }
        
        var contactFieldIdParam: Int? = nil
        var contactFieldValueParam: String? = nil
        
        let expectation = XCTestExpectation(description: "waitForContactClient")
        fakeContactClient.when(\.linkContact) { invocationCount, params in
            contactFieldIdParam = try params[0].unwrap()
            contactFieldValueParam = try params[1].unwrap()
            expectation.fulfill()
            return
        }
        
        try await linkContactState.active()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(contactFieldIdParam, 123)
        XCTAssertEqual(contactFieldValueParam, "testContactFieldValue")
    }
    
    func testActive_whenContactFieldIdAndOpenIdTokenValueIsNotNil() async throws {
        fakeSecureStorage.when(\.get) { invocationCount, params in
            let key: String! = try params[0].unwrap()
            var result: Any?
            switch key {
            case Constants.Contact.contactFieldId:
                result = 123
            case Constants.Contact.openIdToken:
                result = "testOpenIdToken"
            default:
                result = nil
            }
            return result
        }
        
        var contactFieldIdParam: Int? = nil
        var openIdTokenParam: String? = nil
        
        let expectation = XCTestExpectation(description: "waitForContactClient")
        fakeContactClient.when(\.linkContact) { invocationCount, params in
            contactFieldIdParam = try params[0].unwrap()
            openIdTokenParam = try params[2].unwrap()
            expectation.fulfill()
            return
        }
        
        try await linkContactState.active()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(contactFieldIdParam, 123)
        XCTAssertEqual(openIdTokenParam, "testOpenIdToken")
    }
    
}
