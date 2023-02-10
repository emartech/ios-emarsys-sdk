//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class EmarsysClientTests: XCTestCase {

    @Inject(\.sessionContext)
    var sessionContext: SessionContext
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.defaultUrls)
    var defaultUrls: DefaultUrls
    
    @Inject(\.deviceInfoCollector)
    var fakeDeviceInfoCollector: FakeDeviceInfoCollector
    
    @Inject(\.genericNetworkClient)
    var fakeNetworkClient: FakeGenericNetworkClient
    
    @Inject(\.timestampProvider)
    var fakeTimestampProvider: FakeTimestampProvider
    
    var emarsysClient: EmarsysClient!
    
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
    var requiredHeaders: [String: String]!
    
    override func setUpWithError() throws {
        try! super.setUpWithError()

        fakeTimestampProvider.when(\.provideFuncName) { invocationCount, params in
            return Date(timeIntervalSince1970: 50000)
        }
        
        requiredHeaders = [
            "X-Client-State": testClientState,
            "X-Client-Id": testClientId,
            "X-Contact-Token": testContactToken,
            "X-Request-Order": "\(Date(timeIntervalSince1970: 50000).timeIntervalSince1970 * 1000)"
        ]
        sessionContext.contactToken = testContactToken
        sessionContext.clientId = testClientId
        sessionContext.clientState = testClientState
        emarsysClient = EmarsysClient(networkClient: fakeNetworkClient, deviceInfoCollector: fakeDeviceInfoCollector, defaultUrls: defaultUrls, sdkContext: sdkContext, sessionContext: sessionContext)
    }

    func testSend_withoutInput_withData_shouldExtendHeaders_withRequiredHeaders() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        
        var requestInNetworkCall: URLRequest!
        fakeNetworkClient.when(\.send) { invocationNumber, args in
            requestInNetworkCall = try args[0].unwrap()
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
        fakeNetworkClient.when(\.send) { invocationNumber, args in
            requestInNetworkCall = try args[0].unwrap()
            return (testDennaResponse, HTTPURLResponse())
        }
        
        let result: (DennaResponse<TestBody>, HTTPURLResponse) = try await emarsysClient.send(request: request)
        
        XCTAssertEqual(testBody, result.0.body)
        XCTAssertTrue(requestInNetworkCall.allHTTPHeaderFields!.subDict(dict: requiredHeaders))
    }
    
    func testSend_withInput_withData_shouldExtendHeaders_withRequiredHeaders() async throws {
        let body = bodyDict.toData()
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: body)
        
        var requestInNetworkCall: URLRequest!
        
        fakeNetworkClient.when(\.sendWithBody) { invocationNumber, args in
            requestInNetworkCall = try args[0].unwrap()
            return (body, HTTPURLResponse())
        }
        
        let result: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request, body: testBody)
        
        XCTAssertEqual(bodyDict.toData(), result.0)
        XCTAssertTrue(requestInNetworkCall.allHTTPHeaderFields!.subDict(dict: requiredHeaders))
    }
    
    func testSend_withInput_withDecodableValue_shouldExtendHeaders_withRequiredHeaders() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let testDennaResponse = DennaResponse(method: "POST", headers: headers, body: testBody)
        
        var requestInNetworkCall: URLRequest!
        
        fakeNetworkClient.when(\.sendWithBody) { invocationNumber, args in
            requestInNetworkCall = try args[0].unwrap()
            return (testDennaResponse, HTTPURLResponse())
        }
        
        let result: (DennaResponse<TestBody>, HTTPURLResponse) = try await emarsysClient.send(request: request, body: testBody)
        
        XCTAssertEqual(testBody, result.0.body)
        XCTAssertTrue(requestInNetworkCall.allHTTPHeaderFields!.subDict(dict: requiredHeaders))
    }

    func testSend_withoutInput_withData_shouldStoreClientState_toSessionContext_whenClientState_isPresent() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        
        fakeNetworkClient.when(\.send) { invocationNumber, args in
            return (self.bodyDict.toData(), HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: [  "X-Client-State": "clientState" ]))
        }
        
        let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
        
        XCTAssertEqual(sessionContext.clientState,"clientState")
    }

    func testSend_withoutInput_withBody_shouldStoreClientState_toSessionContext_whenClientState_isPresent() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())

        fakeNetworkClient.when(\.sendWithBody) { invocationNumber, args in
            return (self.bodyDict.toData(), HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: [  "X-Client-State": "clientState" ]))
        }

        let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request,body: testBody)

        XCTAssertEqual(sessionContext.clientState,"clientState")
    }

    func testSend_withoutInput_shouldRefreshTheContactToken_whenResponseStatus_is401() async throws {
        let testRefreshResponse = ["contactToken": "refreshedContactToken"]
        let finalResponseBody =  ["finalKey": "finalValue"]
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        
        let responseWithErrorStatus = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        let refreshResponse = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseWithSuccess = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        
        var finalRequestInSend: URLRequest!
        
        fakeNetworkClient.when(\.send) { invocationNumber, args in
            switch (invocationNumber) {
            case 1: return (self.bodyDict.toData(), responseWithErrorStatus)
                
            case 2: return (testRefreshResponse.toData(), refreshResponse)
                
            case 3:
                finalRequestInSend = try args[0].unwrap()
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

    func testSend_withoutInput_shouldThrowMappingFailedError_ifNewContactTokenIsMissing() async throws {
        let request = URLRequest.create(url: URL(string: "https://emarsys.com")!, method: .POST, headers: headers, body: bodyDict.toData())
        let responseWithErrorStatus = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        let refreshResponse = HTTPURLResponse(url:URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let testRefreshResponseWithMissingToken = ["contactToken": 123]
        
        fakeNetworkClient.when(\.send) { invocationNumber, args in
            switch (invocationNumber) {
            case 1: return (self.bodyDict.toData(), responseWithErrorStatus)
                
            case 2: return (testRefreshResponseWithMissingToken.toData(), refreshResponse)
                
            default:
                return (self.bodyDict.toData(), responseWithErrorStatus)
            }
        }
        
        let expectedError = Errors.TypeError.mappingFailed(parameter: String(describing: testRefreshResponseWithMissingToken["contactToken"]), toType: String(describing: String.self))
        
        await assertThrows(expectedError: expectedError) {
            let _: (Data, HTTPURLResponse) = try await emarsysClient.send(request: request)
        }
    }
}
