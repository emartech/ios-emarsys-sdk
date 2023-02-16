//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
final class RegisterPushTokenStateTests: XCTestCase {

    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage
    
    @Inject(\.pushClient)
    var fakePushClient: FakePushClient
    
    var registerPushTokenState: RegisterPushTokenState!
    
    override func setUpWithError() throws {
        registerPushTokenState = RegisterPushTokenState(pushClient: fakePushClient, secureStorage: fakeSecureStorage)
    }

    func testActive_whenLastSentPushTokenIsMissing_pushTokenIsAvailable() async throws {
        let expectedPushToken = "testPushToken"
        
        fakeSecureStorage.when(\.get) { invocationCount, params in
            let key: String! = try params[0].unwrap()
            var result: String? = nil
            if key == "pushToken" {
                result = expectedPushToken
            }
            return result
        }
        var pushTokenParam: String? = nil
        var pushTokenToStore: String? = nil
        
        let expectation = XCTestExpectation(description: "waitForRegisterPushToken")
        expectation.expectedFulfillmentCount = 2
        fakePushClient.when(\.registerPushToken) { invocationCount, params in
            pushTokenParam = try params[0].unwrap()
            expectation.fulfill()
            return
        }
        fakeSecureStorage.when(\.put) { invocationCount, params in
            pushTokenToStore = try params[0].unwrap()
            expectation.fulfill()
            return
        }
        
        _ = try await registerPushTokenState.active()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(pushTokenParam, expectedPushToken)
        XCTAssertEqual(pushTokenToStore, expectedPushToken)
    }
    
    func testActive_whenBothAvailable_butNotTheSame() async throws {
        let expectedPushToken = "testPushToken"
        
        fakeSecureStorage.when(\.get) { invocationCount, params in
            let key: String! = try params[0].unwrap()
            var result: String? = nil
            if key == "pushToken" {
                result = expectedPushToken
            } else if key == "lastSentPushToken" {
                result = "testLastSentPushToken"
            }
            return result
        }
        var pushTokenParam: String? = nil
        var pushTokenToStore: String? = nil
        
        let expectation = XCTestExpectation(description: "waitForRegisterPushToken")
        expectation.expectedFulfillmentCount = 2
        fakePushClient.when(\.registerPushToken) { invocationCount, params in
            pushTokenParam = try params[0].unwrap()
            expectation.fulfill()
            return
        }
        fakeSecureStorage.when(\.put) { invocationCount, params in
            pushTokenToStore = try params[0].unwrap()
            expectation.fulfill()
            return
        }
        
        _ = try await registerPushTokenState.active()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(pushTokenParam, expectedPushToken)
        XCTAssertEqual(pushTokenToStore, expectedPushToken)
    }

    
    func testActive_whenBothAvailable_andTheSame() async throws {
        let expectedPushToken = "testPushToken"
        
        fakeSecureStorage.when(\.get) { invocationCount, params in
            let key: String! = try params[0].unwrap()
            var result: String? = nil
            if key == "pushToken" {
                result = expectedPushToken
            } else if key == "lastSentPushToken" {
                result = expectedPushToken
            }
            return result
        }
        var pushTokenParam: String? = nil
        var pushTokenToStore: String? = nil
        
        let expectation = XCTestExpectation(description: "waitForRegisterPushToken")
        expectation.expectedFulfillmentCount = 2
        fakePushClient.when(\.registerPushToken) { invocationCount, params in
            pushTokenParam = try params[0].unwrap()
            expectation.fulfill()
            return
        }
        fakeSecureStorage.when(\.put) { invocationCount, params in
            pushTokenToStore = try params[0].unwrap()
            expectation.fulfill()
            return
        }
        
        _ = try await registerPushTokenState.active()
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(waiterResult, .timedOut)
        XCTAssertNil(pushTokenParam)
        XCTAssertNil(pushTokenToStore)
    }

    
}
