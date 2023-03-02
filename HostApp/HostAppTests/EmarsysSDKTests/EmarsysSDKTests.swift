import XCTest
@testable import EmarsysSDK

@SdkActor
final class EmarsysSDKTests: EmarsysTestCase {
    
    let applicationCode = "testApplicationCode"
    let merchantId = "testMerchantId"
    
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
        
        let testEmarsysConfig = EmarsysConfig(
            applicationCode:testAppcode,
            merchantId:testMerchantId
        )
        try await EmarsysSDK.enableTracking(testEmarsysConfig)
        
        XCTAssertEqual(DependencyInjection.container?.sdkContext.config, testEmarsysConfig)
    }
    
    func testEnableTracking_shouldCallSetupOnSetupOrganizer() async throws {
        await EmarsysSDK.initialize()
        let testAppcode = "EMS11-C3FD3"
        let testMerchantId = "testMerchantId"
        
        let testEmarsysConfig = EmarsysConfig(
            applicationCode:testAppcode,
            merchantId:testMerchantId
        )
        try await EmarsysSDK.enableTracking(testEmarsysConfig)
        
        XCTAssertEqual(DependencyInjection.container?.sdkContext.sdkState, .active)
    }
    
    func testInitialize_shouldBeInitialized_whenOnly_ApplicationCode_isUsed() async throws {
        let config = EmarsysConfig(applicationCode: applicationCode)
        
        XCTAssertEqual(config.applicationCode, applicationCode)
    }
    
    func testInitialize_shouldBeInitialized_whenOnly_MerchantId_isUsed() async throws {
        let config = EmarsysConfig(merchantId: merchantId)
        
        XCTAssertEqual(config.merchantId, merchantId)
    }
    
    func testEnableTracking_shouldThrowAnError_whenBothApplicationCodeAndMerchantId_areMissing() async throws {
        await EmarsysSDK.initialize()
        let config = EmarsysConfig()
        let expectedError = Errors.preconditionFailed(message: "ApplicationCode or MerchantId must be present for Tracking")
        
        await assertThrows( expectedError:expectedError ) {
            try await EmarsysSDK.enableTracking(config)
        }
    }
}
