import Foundation

import XCTest
@testable import EmarsysSDK

@SdkActor
final class DefaultRemoteConfigClientTests: XCTestCase {
    
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
    var jsonDecoder: JSONDecoder!
    var jsonEncoder: JSONEncoder!
    
    override func setUpWithError() throws {
        jsonDecoder = JSONDecoder()
        jsonEncoder = JSONEncoder()
        remoteConfigClient = DefaultRemoteConfigClient(networkClient: fakeNetworkClient,
                                                       sdkContext: sdkContext,
                                                       crypto: fakeCrypto,
                                                       jsonDecoder: jsonDecoder,
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
    
    func testFetchRemoteConfig_shouldReturnRemoteConfig_whenVerificationSucceeds() async throws {
        let serviceUrls = ServiceUrls(eventService: "https://base.mobile-events.eservice.emarsys.net",
                                      clientService: "https://base.me-client.eservice.emarsys.net",
                                      predictService: "https://base.predict.eservice.emarsys.net",
                                      deepLinkService: "https://base.deeplink.eservice.emarsys.net",
                                      inboxService: "https://base.inbox.eservice.emarsys.net")
        let loglevel = "warn"
        let features1 = RemoteConfigFeatures(mobileEngage: true, predict: false)
        let features2 = RemoteConfigFeatures(mobileEngage: false, predict: true)
        
        let overrideConfig = RemoteConfig(serviceUrls: serviceUrls, logLevel: "debug", features: features2)
        let overridesDict = ["testHwId": overrideConfig]
        let responseRemoteConfig = RemoteConfigResponse(serviceUrls: serviceUrls,
                                                        logLevel: loglevel,
                                                        luckyLogger: nil,
                                                        features: features1,
                                                        overrides: overridesDict)
        
        let responseData = try jsonEncoder.encode(responseRemoteConfig)
        fakeNetworkClient.when(\.send) { invocationCount, params in
            return (responseData, HTTPURLResponse(url: URL(string: "https://emarsys.com")!, statusCode: 200, httpVersion: nil, headerFields: nil))
        }
        
        var counter = 0
        fakeCrypto.when(\.verify) { invocationCount, params in
            counter = invocationCount
            return true
        }
        
        let result :RemoteConfigResponse? = try await remoteConfigClient.fetchRemoteConfig()
        
        XCTAssertEqual(counter, 1)
        XCTAssertEqual(result, responseRemoteConfig)
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

        let result :RemoteConfigResponse? = try await remoteConfigClient.fetchRemoteConfig()
        
        XCTAssertEqual(counter, 1)
        XCTAssertNil(result)
    }
}
