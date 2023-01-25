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
        sdkContext.config = Config(applicationCode: "testAppCode")
        emarsysClient = EmarsysClient(networkClient: fakeNetworkClient, deviceInfoCollector: deviceInfoCollector, defaultValues: defaultValues, sdkContext: sdkContext, sessionContext: fakeSessionContext)
    }

    func testSend_withoutInput_withData_shouldExtendHeaders_withRequiredHeaders() async throws {
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())

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
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
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
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())

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
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
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
}
