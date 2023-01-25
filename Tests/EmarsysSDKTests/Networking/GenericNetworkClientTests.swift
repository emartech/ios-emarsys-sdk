//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
import XCTest
@testable import EmarsysSDK

@SdkActor
final class GenericNetworkClientTests: XCTestCase {

    let bodyDict = [
        "testKey1": "testValue1",
        "testKey2": [
            "testKey3": "testValue3",
            "testKey4": ["1", "2", "3"]
        ],
        "testKey5": true,
        "testKey6": 123
    ] as [String: Any]

    let testBody = TestBody(testKey1: "testValue1",
            testKey2: InnerObject(testKey3: "testValue3",
                    testKey4: ["1", "2", "3"]),
            testKey5: true,
            testKey6: 123)

    let headers = [
        "content-type": "application/json",
        "accept": "application/json",
        "headername1": "headerValue1",
        "headername2": "headerValue2"
    ]

    var networkClient: GenericNetworkClient!

    override func setUp() async throws {
        let session = URLSession.shared
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        networkClient = GenericNetworkClient(session: session, decoder: decoder, encoder: encoder)
    }

    func testSend_withoutInput_withData() async throws {
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: request)

        let resultDict = result.0.toDict()
        let resultMethod = resultDict["method"] as! String
        let resultHeaders = resultDict["headers"] as! [String: String]
        let resultBody = resultDict["body"] as! [String: Any]

        XCTAssertEqual(resultMethod, "POST")
        XCTAssertTrue(resultHeaders.subDict(dict: headers))
        XCTAssertTrue(bodyDict.equals(dict: resultBody))
    }

    func testSend_withoutInput_withDecodableValue() async throws {
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
        let result: (DennaResponse<TestBody>, HTTPURLResponse) = try await networkClient.send(request: request)

        let resultMethod = result.0.method
        let resultHeaders = result.0.headers
        let resultBody = result.0.body

        XCTAssertEqual(resultMethod, "POST")
        XCTAssertTrue(resultHeaders.subDict(dict: headers))
        XCTAssertEqual(resultBody, testBody)
    }

    func testSend_withoutInput_withThrowingDecodingFailedError() async throws {
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
        let expectedError = Errors.NetworkingError.decodingFailed("decodingFailed".localized(with: String(describing: DefaultValues.self)))

        await assertThrows(expectedError: expectedError) {
            let _: (DefaultValues, HTTPURLResponse) = try await networkClient.send(request: request)
        }
    }

    func testSend_withInput_withData() async throws {
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: request, body: testBody)

        let resultDict = result.0.toDict()
        let resultMethod = resultDict["method"] as! String
        let resultHeaders = resultDict["headers"] as! [String: String]
        let resultBody = resultDict["body"] as! [String: Any]

        XCTAssertEqual(resultMethod, "POST")
        XCTAssertTrue(resultHeaders.subDict(dict: headers))
        XCTAssertTrue(bodyDict.equals(dict: resultBody))
    }

    func testSend_withInput_withDecodableValue() async throws {
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
        let result: (DennaResponse<TestBody>, HTTPURLResponse) = try await networkClient.send(request: request, body: testBody)

        let resultMethod = result.0.method
        let resultHeaders = result.0.headers
        let resultBody = result.0.body

        XCTAssertEqual(resultMethod, "POST")
        XCTAssertTrue(resultHeaders.subDict(dict: headers))
        XCTAssertEqual(resultBody, testBody)
    }

    func testSend_withInput_withThrowingDecodingFailedError() async throws {
        let request = URLRequest.create(url: URL(string: "https://denna.gservice.emarsys.net/echo")!, method: .POST, headers: headers, body: bodyDict.toData())
        let expectedError = Errors.NetworkingError.decodingFailed("decodingFailed".localized(with: String(describing: DefaultValues.self)))

        await assertThrows(expectedError: expectedError) {
            let _: (DefaultValues, HTTPURLResponse) = try await networkClient.send(request: request, body: testBody)
        }
    }

}

struct InnerObject: Decodable, Encodable, Equatable {
    let testKey3: String
    let testKey4: [String]
}

struct TestBody: Decodable, Encodable, Equatable {
    let testKey1: String
    let testKey2: InnerObject
    let testKey5: Bool
    let testKey6: Int

    static func ==(lhs: TestBody, rhs: TestBody) -> Bool {
        return lhs.testKey1 == rhs.testKey1 &&
                lhs.testKey2 == rhs.testKey2 &&
                lhs.testKey5 == rhs.testKey5 &&
                lhs.testKey6 == rhs.testKey6
    }
}
