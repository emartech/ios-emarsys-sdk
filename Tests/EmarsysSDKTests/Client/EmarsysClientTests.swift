//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class EmarsysClientTests: XCTestCase {
    var emarsysClient: EmarsysClient!

    var fakeTimestampProvider: FakeTimestampProvider!
    var fakeSessionContext: SessionContext!
    var fakeNetworkClient: FakeGenericNetworkClient!
    var deviceInfoCollector: DeviceInfoCollector!
    var defaultValues: DefaultValues!
    var sdkContext: SdkContext!

    let headers = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "headerName1": "headerValue1",
        "headerName2": "headerValue2"
    ]
    
    let testBody = TestBody(testKey1: "testValue1",
            testKey2: InnerObject(testKey3: "testValue3",
                    testKey4: ["1", "2", "3"]),
            testKey5: true,
            testKey6: 123)
    
    let bodyDict = [
        "testKey1": "testValue1",
        "testKey2": [
            "testKey3": "testValue3",
            "testKey4": ["1", "2", "3"]
        ],
        "testKey5": true,
        "testKey6": 123
    ] as [String: Any]
    
    let testClientState = "testClientState"
    let testClientId = "testClientId"
    let testContactToken = "testContactToken"
    let testDate = Date(timeIntervalSince1970: 50000)
    var testTimestamp: String!
    var requiredHeaders: [String: String]!

    override func setUp() async throws {
        testTimestamp = "\(testDate)"
        requiredHeaders = [
            "X-Client-State": testClientState,
            "X-Client-Id": testClientId,
            "X-Contact-Token": testContactToken,
            "X-Request-Order": testTimestamp
        ]

        fakeTimestampProvider = FakeTimestampProvider()
        fakeSessionContext = FakeSessionContext(timestampProvider: fakeTimestampProvider)
        fakeSessionContext.contactToken = testContactToken
        fakeNetworkClient = FakeGenericNetworkClient()
        deviceInfoCollector = DeviceInfoCollector()
        defaultValues = DefaultValues(
                version: "1.0",
                clientServiceBaseUrl: "www.client.service.url",
                eventServiceBaseUrl: "www.event.service.url",
                predictBaseUrl: "www.predict.service.url",
                deepLinkBaseUrl: "www.deeplink.service.url",
                inboxBaseUrl: "www.inbox.service.url",
                remoteConfigBaseUrl: "www.remote.config.service.url"
        )
        sdkContext = SdkContext()
        sdkContext.config = EmarsysConfig(applicationCode: "testAppCode")
        emarsysClient = EmarsysClient(networkClient: fakeNetworkClient, deviceInfoCollector: deviceInfoCollector, defaultValues: defaultValues, sdkContext: sdkContext, sessionContext: fakeSessionContext)
    }

    func testSend_withoutInput_withData_shouldExtendHeaders_withRequiredHeaders() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())

        var requestInNetworkCall: URLRequest!

        fakeNetworkClient.when("send") { invocationNumber, args in
            requestInNetworkCall = (args[0] as! Array<Any?>)[0] as? URLRequest
            return (self.bodyDict.toData(), HTTPURLResponse())
        }

        let result: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)

        XCTAssertEqual(bodyDict.toData(), result.0)
        XCTAssertTrue(requestInNetworkCall.allHTTPHeaderFields!.subDict(dict: requiredHeaders))
    }
    
    func testSend_withoutInput_withDecodableValue_shouldExtendHeaders_withRequiredHeaders() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let testDennaResponse = DennaResponse(method: "POST", headers: headers, body: testBody)

        var requestInNetworkCall: URLRequest!

        fakeNetworkClient.when("send") { invocationNumber, args in
            requestInNetworkCall = (args[0] as! Array<Any?>)[0] as? URLRequest
            return (testDennaResponse, HTTPURLResponse())
        }

        let result: (DennaResponse<TestBody>, HTTPURLResponse) = try await emarsysClient.send(request: request)

        XCTAssertEqual(testBody, result.0.body)
        XCTAssertTrue(requestInNetworkCall.allHTTPHeaderFields!.subDict(dict: requiredHeaders))
    }
    
    func testSend_withInput_withData_shouldExtendHeaders_withRequiredHeaders() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())

        var requestInNetworkCall: URLRequest!

        fakeNetworkClient.when("send") { invocationNumber, args in
            requestInNetworkCall = (args[0] as! Array<Any?>)[0] as? URLRequest
            return (self.bodyDict.toData(), HTTPURLResponse())
        }

        let result: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request, body: testBody)

        XCTAssertEqual(bodyDict.toData(), result.0)
        XCTAssertTrue(requestInNetworkCall.allHTTPHeaderFields!.subDict(dict: requiredHeaders))
    }
    
    func testSend_withInput_withDecodableValue_shouldExtendHeaders_withRequiredHeaders() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let testDennaResponse = DennaResponse(method: "POST", headers: headers, body: testBody)

        var requestInNetworkCall: URLRequest!

        fakeNetworkClient.when("send") { invocationNumber, args in
            requestInNetworkCall = (args[0] as! Array<Any?>)[0] as? URLRequest
            return (testDennaResponse, HTTPURLResponse())
        }

        let result: (DennaResponse<TestBody>, HTTPURLResponse) = try await emarsysClient.send(request: request, body: testBody)

        XCTAssertEqual(testBody, result.0.body)
        XCTAssertTrue(requestInNetworkCall.allHTTPHeaderFields!.subDict(dict: requiredHeaders))
    }
    
    func testSend_withoutInput_shouldRefreshTheContactToken_whenResponseStatus_is401() async throws {
        let testRefreshResponse = ["contactToken": "refreshedContactToken"]
        let finalResponseBody =  ["finalKey": "finalValue"]
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        
        let responseWithErrorStatus = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        let refreshResponse = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseWithSuccess = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        
        var finalRequestInSend: URLRequest!
        
        fakeNetworkClient.when("send") { invocationNumber, args in
            switch (invocationNumber) {
            case 1: return (self.bodyDict.toData(), responseWithErrorStatus)
                
            case 2: return (testRefreshResponse.toData(), refreshResponse)
                
            case 3:
                finalRequestInSend = (args[0] as! Array<Any?>)[0] as? URLRequest
                return (finalResponseBody.toData(), responseWithSuccess)
    
            default:
                return (self.bodyDict.toData(), responseWithErrorStatus)
            }
        }
        
        let result: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
        
        let finalResult = result.0.toDict()["finalKey"] as! String
        
        let expectedContactTokenHeader = ["X-Contact-Token": "refreshedContactToken"]
        
        XCTAssertEqual(finalResult, "finalValue")
        XCTAssertTrue(finalRequestInSend.allHTTPHeaderFields!.subDict(dict: expectedContactTokenHeader))
    }
    
    func testSend_withoutInput_shouldThrowPreconditionFailedError_whenConfigIsNil() async throws {
        let sdkContextWithEmptyConfig = SdkContext()
        sdkContextWithEmptyConfig.config = nil
        let emsClient = EmarsysClient(networkClient: fakeNetworkClient, deviceInfoCollector: deviceInfoCollector, defaultValues: defaultValues, sdkContext: sdkContextWithEmptyConfig, sessionContext: fakeSessionContext)
        
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let responseWithErrorStatus = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        
        fakeNetworkClient.when("send") { invocationNumber, args in
            switch (invocationNumber) {
            case 1: return (self.bodyDict.toData(), responseWithErrorStatus)
    
            default:
                return (self.bodyDict.toData(), responseWithErrorStatus)
            }
        }
        
        let expectedError = Errors.preconditionFailed("preconditionFailed".localized(with: "Config must not be nil"))
        
        await assertThrows(expectedError: expectedError) {
            let _: (Data, HTTPURLResponse) = try await emsClient.send(request: request)
        }
    }

    func testSend_withoutInput_shouldThrowPreconditionFailedError_whenAppcodeIsNil() async throws {
        let testSdkContext = SdkContext()
        let emptyConfig = EmarsysConfig()
        testSdkContext.config = emptyConfig
        
        let emsClient = EmarsysClient(networkClient: fakeNetworkClient, deviceInfoCollector: deviceInfoCollector, defaultValues: defaultValues, sdkContext: testSdkContext, sessionContext: fakeSessionContext)
        
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let responseWithErrorStatus = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        
        fakeNetworkClient.when("send") { invocationNumber, args in
            switch (invocationNumber) {
            case 1: return (self.bodyDict.toData(), responseWithErrorStatus)
    
            default:
                return (self.bodyDict.toData(), responseWithErrorStatus)
            }
        }
        
        let expectedError = Errors.preconditionFailed("preconditionFailed".localized(with: "Application code must not be nil"))
        
        await assertThrows(expectedError: expectedError) {
            let _: (Data, HTTPURLResponse) = try await emsClient.send(request: request)
        }
    }
    
    func testSend_withoutInput_shouldThrowUrlCreationFailedError() async throws {
        let testDefaultValues = DefaultValues(
            version: "1.0",
            clientServiceBaseUrl: "invalid base.url",
            eventServiceBaseUrl: "www.event.service.url",
            predictBaseUrl: "www.predict.service.url",
            deepLinkBaseUrl: "www.deeplink.service.url",
            inboxBaseUrl: "www.inbox.service.url",
            remoteConfigBaseUrl: "www.remote.config.service.url"
        )
        
        let emsClient = EmarsysClient(networkClient: fakeNetworkClient, deviceInfoCollector: deviceInfoCollector, defaultValues: testDefaultValues, sdkContext: sdkContext, sessionContext: fakeSessionContext)
        
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let responseWithErrorStatus = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        
        fakeNetworkClient.when("send") { invocationNumber, args in
            switch (invocationNumber) {
            case 1: return (self.bodyDict.toData(), responseWithErrorStatus)
    
            default:
                return (self.bodyDict.toData(), responseWithErrorStatus)
            }
        }
        
        let expectedError = Errors.urlCreationFailed("urlCreationFailed".localized(with: "invalid base.url/v3/apps/testAppCode/client/contact-token"))
        
        await assertThrows(expectedError: expectedError) {
            let _: (Data, HTTPURLResponse) = try await emsClient.send(request: request)
        }
    }
    
    func testSend_withoutInput_shouldThrowMappingFailedError_ifNewContactTokenIsMissing() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let responseWithErrorStatus = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        let refreshResponse = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let testRefreshResponseWithMissingToken = ["contactToken": 123]
        
        fakeNetworkClient.when("send") { invocationNumber, args in
            switch (invocationNumber) {
            case 1: return (self.bodyDict.toData(), responseWithErrorStatus)
                
            case 2: return (testRefreshResponseWithMissingToken.toData(), refreshResponse)
                
            default:
                return (self.bodyDict.toData(), responseWithErrorStatus)
            }
        }
        
        let expectedError = Errors.mappingFailed("mappingFailed".localized(with: "\(String(describing: testRefreshResponseWithMissingToken["contactToken"]))", "String"))
        
        await assertThrows(expectedError: expectedError) {
            let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
        }
    }
}
