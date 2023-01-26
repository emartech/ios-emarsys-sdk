import XCTest
@testable import EmarsysSDK

@SdkActor
final class EmarsysSDKTests: XCTestCase {
    
    override func tearDown() {
        DependencyInjection.tearDown()
    }

    func testInitialize_shouldSetSdkStateToOnHold() async throws {       
        await EmarsysSDK.initialize()
       
        let resultState = DependencyInjection.container?.sdkContext.sdkState
        
        XCTAssertEqual(resultState, .onHold)
    }
    
    func testEnableTracking_shouldSetConfigOnSdkContext() async throws {
        await EmarsysSDK.initialize()
        let testAppcode = "testAppcode"
        let testMerchantId = "testMerchantId"
        let logLevels: [LogLevel] = [.Metric, .Debug, .Error]

        let testEmarsysConfig = EmarsysConfig(
        applicationCode:testAppcode,
        merchantId:testMerchantId,
        enabledLogLevels: logLevels
        )
        await EmarsysSDK.enableTracking(testEmarsysConfig)

        XCTAssertEqual(DependencyInjection.container?.sdkContext.config, testEmarsysConfig) 
    }

    func testEnableTracking_shouldCallSetupOnSetupOrganizer() async throws {
        await EmarsysSDK.initialize()
        let testAppcode = "testAppcode"
        let testMerchantId = "testMerchantId"
        let logLevels: [LogLevel] = [.Metric, .Debug, .Error]

        let testEmarsysConfig = EmarsysConfig(
        applicationCode:testAppcode,
        merchantId:testMerchantId,
        enabledLogLevels: logLevels
        )
        await EmarsysSDK.enableTracking(testEmarsysConfig)

        XCTAssertEqual(DependencyInjection.container?.sdkContext.sdkState, .active) 
    }
    
}
