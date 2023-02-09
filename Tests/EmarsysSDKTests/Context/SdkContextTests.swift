//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
final class SdkContextTests: XCTestCase {

    var defaultUrls: DefaultUrls!
    var sdkContext: SdkContext!
    
    override func setUpWithError() throws {
        defaultUrls = DefaultUrls(
            clientServiceBaseUrl: "www.client.service.url",
            eventServiceBaseUrl: "www.event.service.url",
            predictBaseUrl: "www.predict.service.url",
            deepLinkBaseUrl: "invalid base url",
            inboxBaseUrl: "www.inbox.service.url",
            remoteConfigBaseUrl: "www.remote.config.service.url"
        )
        let sdkConfig = SdkConfig(version: "testVersion", cryptoPublicKey: "testCryptoPublicKey", remoteLogLevel: "testLogLevel")
        sdkContext = SdkContext(sdkConfig: sdkConfig, defaultUrls: defaultUrls)
        sdkContext.config = EmarsysConfig(applicationCode: "testApplicationCode")
    }

    func testCreateUrl() throws {
        let expected = URL(string: "www.remote.config.service.url/v3/apps/testApplicationCode/testPath")
        
        let result = try sdkContext.createUrl(\.remoteConfigBaseUrl, path: "/testPath")
        
        XCTAssertEqual(expected, result)
    }
    
    func testCreateUrl_when_configIsNil() async throws {
        sdkContext.config = nil
        
        let expectedError = Errors.preconditionFailed(message: "Config must not be nil")
        
        await assertThrows(expectedError: expectedError) {
            let _ = try sdkContext.createUrl(\.remoteConfigBaseUrl)
        }
    }
    
    func testCreateUrl_when_AppCodeIsNil() async throws {
        sdkContext.config?.applicationCode = nil
        
        let expectedError = Errors.preconditionFailed(message: "Application code must not be nil")
        
        await assertThrows(expectedError: expectedError) {
            let _ = try sdkContext.createUrl(\.remoteConfigBaseUrl)
        }
    }
    
    func testCreateUrl_when_urlCreationFailed() async throws {
        let expectedError = Errors.NetworkingError.urlCreationFailed(url: "invalid base url/v3/apps/testApplicationCode")
        
        await assertThrows(expectedError: expectedError) {
            let _ = try sdkContext.createUrl(\.deepLinkBaseUrl)
        }
    }

}
