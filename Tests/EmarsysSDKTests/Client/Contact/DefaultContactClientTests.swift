//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import XCTest
@testable import EmarsysSDK


@SdkActor
final class DefaultContactClientTests: XCTestCase {
    let contactFieldId = 123
    let contactFieldValue = "testContactFieldValue"
    let openIdToken = "testOpenIdToken"
    let contactToken = "testContactToken"
    let refreshToken = "testRefreshToken"
    
    var fakeEmarsysClient: FakeGenericNetworkClient!
    var defaultValues: DefaultValues!
    var sdkContext: SdkContext!
    var sessionContext: SessionContext!
    var fakeTimestampProvider: FakeTimestampProvider!
    var contactClient: ContactClient!
    var sdkLogger: SDKLogger!

    override func setUpWithError() throws {
        fakeEmarsysClient = FakeGenericNetworkClient()
        defaultValues = DefaultValues(version: "testVersion",
                                      clientServiceBaseUrl: "https://base.me-client.eservice.emarsys.net",
                                      eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                      predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                      deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                      inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                      remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        sdkContext = SdkContext()
        sdkContext.config = EmarsysConfig()
        sdkContext.config?.applicationCode = "EMS11-C3FD3"
        fakeTimestampProvider = FakeTimestampProvider()
        sessionContext = SessionContext(timestampProvider: fakeTimestampProvider)
        sdkLogger = SDKLogger()
        contactClient = DefaultContactClient(emarsysClient: fakeEmarsysClient,
                                            defaultValues: defaultValues,
                                            sdkContext: sdkContext,
                                            sessionContext: sessionContext,
                                            sdkLogger: sdkLogger)
    }
 
    override func tearDownWithError() throws {
        fakeEmarsysClient.tearDown()
    }

    func testLinkContact_shouldThrowErrorWhenApplicationCode_isNil() async throws {
        let expectedError = Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        sdkContext.config?.applicationCode = nil
                
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)
            
            return (Data(), HTTPURLResponse())
        }
        
        await assertThrows(expectedError: expectedError) {
            try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil)
        }
    }

    func testLinkContact_shouldThrowErrorWhenURLCannotBeCreated() async throws {
        let wrongDefaultValues = DefaultValues(version: "testVersion",
                                               clientServiceBaseUrl: "",
                                               eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                               predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                               deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                               inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                               remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        let contactClientWithWrongDefaultValues = DefaultContactClient(emarsysClient: fakeEmarsysClient,
                                                 defaultValues: wrongDefaultValues,
                                                 sdkContext: sdkContext,
                                                 sessionContext: sessionContext,
                                                 sdkLogger: sdkLogger)
        let expectedError = Errors.preconditionFailed(message: "Url cannot be created for linkContactRequest!")
                
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)
            
            return (ContactResponse(contactToken: "", refreshToken: ""), HTTPURLResponse())
        }
        
        await assertThrows(expectedError: expectedError) {
            try await contactClientWithWrongDefaultValues.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil)
        }
    }

    func testLinkContact_shouldThrowErrorWhenContactFieldValueAndOpenIdToken_isNil() async throws {
        let expectedError = Errors.preconditionFailed(message: "Either contactFieldValue or openIdToken must not be nil")
        
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)
            
            return (Data(), HTTPURLResponse())
        }
        
        await assertThrows(expectedError: expectedError) {
            try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: nil, openIdToken: nil)
        }
    }

    func testLinkContact_shouldSendRequestWithEmarsysClient_includingOnlyContactFieldValue_whenOpenIdTokenIsNil() async throws {
        let bodyDict = [
            "contactFieldId": "\(contactFieldId)",
            "contactFieldValue": contactFieldValue
        ]
        let expectedRequest = URLRequest.create(url: URL(string: "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/contact?anonymous=false")!, body: bodyDict.toData())
        
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            let request: URLRequest! = try params[0].unwrap()
            let requestBodyDict = request.httpBody?.toDict() as! [String : String]
            
            XCTAssertEqual(request.url, expectedRequest.url)
            XCTAssertTrue(requestBodyDict.subDict(dict: bodyDict))
            XCTAssertEqual(invocationCount, 1)
            
            return (ContactResponse(contactToken: "", refreshToken: ""), HTTPURLResponse())
        }
        
        try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil)

    }

    func testLinkContact_shouldSendRequestWithEmarsysClient_includingOnlyOpenIdTokenIs_whenContactFieldValueIsNil() async throws {
        let bodyDict = [
            "contactFieldId": "\(contactFieldId)",
            "openIdToken": openIdToken
        ]
        let expectedRequest = URLRequest.create(url: URL(string: "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/contact?anonymous=false")!, body: bodyDict.toData())
        
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            let request: URLRequest! = try params[0].unwrap()
            let requestBodyDict = request.httpBody?.toDict() as! [String : String]
            
            XCTAssertEqual(request.url, expectedRequest.url)
            XCTAssertTrue(requestBodyDict.subDict(dict: bodyDict))
            XCTAssertEqual(invocationCount, 1)
            
            return (ContactResponse(contactToken: "", refreshToken: ""), HTTPURLResponse())
        }
        
        try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: nil, openIdToken: openIdToken)
    }
    

    func testLinkContact_shouldHandleSuccessResponse_andSetTokensOnSessionContext() async throws {
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 1)
            
            return (ContactResponse(contactToken: self.contactToken, refreshToken: self.refreshToken), HTTPURLResponse())
        }
        
        try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil)
        
        XCTAssertEqual(sessionContext.contactToken, contactToken)
        XCTAssertEqual(sessionContext.refreshToken, refreshToken)

    }
    

    func testLinkContact_shouldThrowOnErrorResponse() async throws {
        let errorResponse = HTTPURLResponse(url: URL(string: "https://denna.gservice.emarsys.net/customResponseCode/404")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let expectedError = Errors.UserFacingRequestError.contactRequestFailed(url: String(describing: URL(string: "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/contact?anonymous=false")))
        sessionContext.contactToken = contactToken
        sessionContext.refreshToken = refreshToken
        
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 1)
            
            throw Errors.NetworkingError.failedRequest(response: errorResponse)
        }
        
        await assertThrows(expectedError: expectedError) {
            try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil)
        }
        
        XCTAssertEqual(sessionContext.contactToken, nil)
        XCTAssertEqual(sessionContext.refreshToken, nil)
    }
    
    func testUnlinkContact_shouldThrowErrorWhenApplicationCode_isNil() async throws {
        let expectedError = Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        sdkContext.config?.applicationCode = nil
                
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)
            
            return (ContactResponse(contactToken: "", refreshToken: ""), HTTPURLResponse())
        }
        
        await assertThrows(expectedError: expectedError) {
            try await contactClient.unlinkContact()
        }
    }
    
    func testUnlinkContact_shouldThrowErrorWhenURLCannotBeCreated() async throws {
        let wrongDefaultValues = DefaultValues(version: "testVersion",
                                               clientServiceBaseUrl: "",
                                               eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                               predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                               deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                               inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                               remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        let contactClientWithWrongDefaultValues = DefaultContactClient(emarsysClient: fakeEmarsysClient,
                                                 defaultValues: wrongDefaultValues,
                                                 sdkContext: sdkContext,
                                                 sessionContext: sessionContext,
                                                 sdkLogger: sdkLogger)
        let expectedError = Errors.preconditionFailed(message: "Url cannot be created for linkContactRequest!")
                
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            XCTAssertEqual(invocationCount, 0)
            
            return (ContactResponse(contactToken: "", refreshToken: ""), HTTPURLResponse())
        }
        
        await assertThrows(expectedError: expectedError) {
            try await contactClientWithWrongDefaultValues.unlinkContact()
        }
    }
    
    func testUnLinkContact_shouldSendRequestWithEmarsysClient() async throws {
        sessionContext.contactToken = nil
        sessionContext.refreshToken = nil
        let bodyDict = [String: String]()
        let expectedRequest = URLRequest.create(url: URL(string: "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client/contact?anonymous=true")!, body: bodyDict.toData())
        
        fakeEmarsysClient.when(\.send) { invocationCount, params in
            let request: URLRequest! = try params[0].unwrap()
            let requestBodyDict = request.httpBody?.toDict() as! [String : String]
            
            XCTAssertEqual(request.url, expectedRequest.url)
            XCTAssertTrue(requestBodyDict.isEmpty)
            XCTAssertEqual(invocationCount, 1)
            
            return (ContactResponse(contactToken: self.contactToken, refreshToken: self.refreshToken), HTTPURLResponse())
        }
        
        try await contactClient.unlinkContact()

        XCTAssertEqual(sessionContext.contactToken, contactToken)
        XCTAssertEqual(sessionContext.refreshToken, refreshToken)
    }
}
