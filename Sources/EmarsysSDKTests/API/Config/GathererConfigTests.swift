//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
final class GathererConfigTests: EmarsysTestCase {
    var gathererConfig: GathererConfig!
    var configContext: ConfigContext!
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage!
    
    @Inject(\.sdkLogger)
    var sdkLogger: SdkLogger!
    
    override func setUpWithError() throws {
        fakeSecureStorage
            .when(\.fnGet)
            .thenReturn(nil)
        fakeSecureStorage
            .when(\.fnPut)
            .thenReturn(())
        let configCalls = try! PersistentList<ConfigCall>(id: "configCalls", storage: fakeSecureStorage, sdkLogger: sdkLogger)
        configContext = ConfigContext(calls: configCalls)
        gathererConfig = GathererConfig(configContext: configContext)
    }
    
    func testChangeApplicationCode_shouldAppendEvent_onConfigContext() async throws {
        let expectedCall = ConfigCall.changeApplicationCode(applicationCode: "testApplicationCode")
        
        try await gathererConfig.changeApplicationCode(applicationCode: "testApplicationCode")
        
        XCTAssertEqual(configContext.calls.count, 1)
        XCTAssertEqual(expectedCall, configContext.calls.first)
    }
    
    func testChangeMerchantId_shouldAppendEvent_onConfigContext() async throws {
        let expectedCall = ConfigCall.changeMerchantId(merchantId: "testMerchantId")
        
        try await gathererConfig.changeMerchantId(merchantId: "testMerchantId")
        
        XCTAssertEqual(configContext.calls.count, 1)
        XCTAssertEqual(expectedCall, configContext.calls.first)
    }


    func testCallOrder() async throws {
        let expectedCalls = try PersistentList<ConfigCall>(id: "configCalls", storage: fakeSecureStorage, elements: [
            ConfigCall.changeMerchantId(merchantId: "testMerchantId"),
            ConfigCall.changeApplicationCode(applicationCode: "testApplicationCode")
        ], sdkLogger: sdkLogger)

        try await gathererConfig.changeMerchantId(merchantId: "testMerchantId")
        try await gathererConfig.changeApplicationCode(applicationCode: "testApplicationCode")

        XCTAssertEqual(configContext.calls.count, 2)
        XCTAssertEqual(expectedCalls, configContext.calls)
    }
    
}
