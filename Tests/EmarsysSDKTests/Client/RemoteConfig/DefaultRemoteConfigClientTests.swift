import Foundation

import XCTest
@testable import EmarsysSDK

@SdkActor
final class RemoteConfigClient: XCTestCase {
    
    @Inject(\.genericNetworkClient)
    var fakeNetworkClient: FakeGenericNetworkClient
    
    @Inject(\.sdkLogger)
    var sdkLogger: SdkLogger
    
    @Inject(\.crypto)
    var fakeCrypto: FakeCrypto
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.defaultUrls)
    var defaultUrls: DefaultUrls
    
    var remoteConfigClient: DefaultRemoteConfigClient!
    
    override func setUpWithError() throws {
        try! super.setUpWithError()
        
        remoteConfigClient = DefaultRemoteConfigClient(networkClient: fakeNetworkClient,
                                                       sdkContext: sdkContext,
                                                       crypto: fakeCrypto,
                                                       logger: sdkLogger)
    }
    
    override func tearDownWithError() throws {
        tearDownFakes()
    }
    
    func testFetchRemoteConfig_shouldSendRequest_withRemoteConfigClient() async throws {
        let remoteConfigUrl = (defaultUrls.remoteConfigBaseUrl + "/\(sdkContext.config?.applicationCode ?? "")")
        let signatureUrl = (defaultUrls.remoteConfigBaseUrl + "/signature/\(sdkContext.config?.applicationCode ?? "")")
        
        var counter = 0
        
        fakeNetworkClient.when(\.send) { invocationCount, params in
            switch invocationCount {
            case 1:
                let request: URLRequest! = try params[0].unwrap()
                XCTAssertEqual(request.url?.absoluteString, remoteConfigUrl)
            case 2:
                let request: URLRequest! = try params[0].unwrap()
                XCTAssertEqual(request.url?.absoluteString, signatureUrl)
            default:
                return (Data(), HTTPURLResponse())
            }
            counter = invocationCount
            return (Data(), HTTPURLResponse())
        }
        fakeCrypto.when(\.verify) { invocationCount, params in
            return false
        }
        try await remoteConfigClient.fetchRemoteConfig()
        
        XCTAssertEqual(counter, 2)
    }
    
    func testFetchRemoteConfig_shouldNotCall_crypto_verify_whenSignatureNotFound() async throws {
        fakeNetworkClient.when(\.send) { invocationCount, params in
            if invocationCount == 2 {
                return (Data(), HTTPURLResponse(url: URL(string: "https://emarsys.com")!, statusCode: 404, httpVersion: nil, headerFields: nil))
            } else {
                return (Data(), HTTPURLResponse(url: URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil))
            }
        }
        var counter = 0
        fakeCrypto.when(\.verify) { invocationCount, params in
            counter = invocationCount
            return false
        }
        
        let result = try await remoteConfigClient.fetchRemoteConfig()
        
        XCTAssertEqual(result, nil)
        XCTAssertEqual(counter, 0)
    }
    
    func testFetchRemoteConfig_shouldNotCall_crypto_verify_whenConfigNotFound() async throws {
        fakeNetworkClient.when(\.send) { invocationCount, params in
            if invocationCount == 1 {
                return (Data(), HTTPURLResponse(url: URL(string: "https://emarsys.com")!, statusCode: 404, httpVersion: nil, headerFields: nil))
            } else {
                return (Data(), HTTPURLResponse(url: URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil))
            }
        }
        var counter = 0
        fakeCrypto.when(\.verify) { invocationCount, params in
            counter = invocationCount
            return false
        }
        
        let result = try await remoteConfigClient.fetchRemoteConfig()
        
        XCTAssertEqual(result, nil)
        XCTAssertEqual(counter, 0)
    }
    
    func testFetchRemoteConfig_shouldCall_verify_whenBothConfigAndSignatureFound() async throws {
        let response = try JSONSerialization.data(withJSONObject: ["key":"value"])
        fakeNetworkClient.when(\.send) { invocationCount, params in
            return (response, HTTPURLResponse(url: URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil))
        }
        
        var counter = 0
        fakeCrypto.when(\.verify) { invocationCount, params in
            counter = invocationCount
            return true
        }
        let expected: Dictionary<String , String> = ["key":"value"]
        let result :Dictionary<String , String>? = try await remoteConfigClient.fetchRemoteConfig()
        
        XCTAssertEqual(counter, 1)
        XCTAssertEqual(result, expected)
    }
    
    func testFetchRemoteConfig_shouldReturnNil_whenVerifyFailed() async throws {
        let response = try JSONSerialization.data(withJSONObject: ["key":"value"])
        fakeNetworkClient.when(\.send) { invocationCount, params in
            return (response, HTTPURLResponse(url: URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil))
        }
        
        var counter = 0
        fakeCrypto.when(\.verify) { invocationCount, params in
            counter = invocationCount
            return false
        }
        let expected: Dictionary<String , String>? = nil
        let result :Dictionary<String , String>? = try await remoteConfigClient.fetchRemoteConfig()
        
        XCTAssertEqual(counter, 1)
        XCTAssertEqual(result, expected)
    }
}
