//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class DefaultDeviceClientTests: EmarsysTestCase {

    var fakeDeviceInfoCollector: FakeDeviceInfoCollector!
    var defaultDeviceClient: DeviceClient!
    
    override func setUpWithError() throws {
        try! super.setUpWithError()
        fakeDeviceInfoCollector = FakeDeviceInfoCollector()
        
        defaultDeviceClient = DefaultDeviceClient(emarsysClient: fakeNetworkClient,
                                                  sdkContext: sdkContext,
                                                  deviceInfoCollector: fakeDeviceInfoCollector)
    }
    
    override func tearDownWithError() throws {
        try! super.tearDownWithError()
        fakeDeviceInfoCollector.tearDown()
    }

    func testRegisterClient_shouldSendRequest_withEmarsysClient() async throws {
        let expectation = XCTestExpectation(description: "waitForExpectation")
        fakeDeviceInfoCollector.when(\.collect) { invocationCount, params in
            
            XCTAssertEqual(invocationCount, 1)
            return self.deviceInfo
        }
        
        fakeNetworkClient.when(\.sendWithBody) { invocationCount, params in
            let request: URLRequest! = try params[0].unwrap()
            let requestBody: DeviceInfo! = try params[1].unwrap()
            
            
            XCTAssertEqual(invocationCount, 1)
            XCTAssertEqual(request.url?.absoluteString, "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client")
            XCTAssertEqual(requestBody, self.deviceInfo)
            
            expectation.fulfill()
            return (Data(), HTTPURLResponse())
        }
        
        try await defaultDeviceClient.registerClient()
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRegisterClient_shouldHandleFailedRequestAndThrow() async throws {
        let failedRequestUrl = URL(string: "https://base.me-client.eservice.emarsys.net/v3/apps/EMS11-C3FD3/client")
        let response = HTTPURLResponse(url: failedRequestUrl!,
                                       statusCode: 500, httpVersion: "",
                                       headerFields: [String: String]())!
        
        let expectedError = Errors.UserFacingRequestError.registerClientFailed(url: String(describing: failedRequestUrl?.absoluteString))
        let expectation = XCTestExpectation(description: "waitForExpectation")
        fakeDeviceInfoCollector.when(\.collect) { invocationCount, params in
            
            XCTAssertEqual(invocationCount, 1)
            return self.deviceInfo
        }
        
        fakeNetworkClient.when(\.sendWithBody) { invocationCount, params in
            XCTAssertEqual(invocationCount, 1)
            
            expectation.fulfill()
            throw Errors.NetworkingError.failedRequest(response: response)
        }
        
        await assertThrows(expectedError: expectedError) {
            try await defaultDeviceClient.registerClient()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
