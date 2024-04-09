//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
import mimic
@testable import EmarsysSDK

final class ConfigTests: EmarsysTestCase {
    private let testConfig = EmarsysConfig(applicationCode: "testAppCode", merchantId: "testMerchantId")
    private let testContactFieldId = 123
    private let testHwId = "testHwId"
    private let testLanguageCode = "testLanguageCode"
    private let testSdkVersion = "testVersion"
    private let testPushSettings = PushSettings(
        authorizationStatus: "authorizationStatus",
        soundSetting: "soundSetting",
        badgeSetting: "badgeSetting",
        alertSetting: "alertSetting",
        notificationCenterSetting: "notificationCenterSetting",
        lockScreenSetting: "lockScreenSetting",
        carPlaySetting: "carPlaySetting",
        alertStyle: "alertStyle",
        showPreviewsSetting: "showPreviewsSetting",
        criticalAlertSetting: "criticalAlertSetting",
        providesAppNotificationSettings: "providesAppNotificationSettings",
        scheduledDeliverySetting: "scheduledDeliverySetting",
        timeSensitiveSetting: "timeSensitiveSetting"
    )
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage!
    
    @Inject(\.sdkLogger)
    var sdkLogger: SdkLogger!

    
    @Inject(\.deviceInfoCollector)
    var fakeDeviceInfoCollector: FakeDeviceInfoCollector
    
    @Inject(\.configInternal)
    var fakeConfigInternal: FakeConfigInternal
    
    private var config: Config<LoggingConfig, GathererConfig, FakeConfigInternal>!

    override func setUpWithError() throws {
        fakeSecureStorage
            .when(\.fnGet)
            .thenReturn(nil)
        fakeSecureStorage
            .when(\.fnPut)
            .thenReturn(())
        self.sdkContext.config = testConfig
        self.sdkContext.contactFieldId = testContactFieldId
        self.sdkContext.setFeatures(features: [.mobileEngage])
        self.sdkContext.setSdkState(sdkState: .active)
        
        self.fakeDeviceInfoCollector.when(\.fnHardwareId).thenReturn(testHwId)
        self.fakeDeviceInfoCollector.when(\.fnLanguageCode).thenReturn(testLanguageCode)
        self.fakeDeviceInfoCollector.when(\.fnPushSettings).thenReturn(testPushSettings)
        
        let configCalls = try! PersistentList<ConfigCall>(id: "configCalls", storage: fakeSecureStorage, sdkLogger: sdkLogger)
        let configContext = ConfigContext(calls: configCalls)
        
        self.config = Config(loggingInstance: LoggingConfig(logger: self.sdkLogger), gathererInstance: GathererConfig(configContext: configContext), internalInstance: self.fakeConfigInternal, sdkContext: self.sdkContext, deviceInfoCollector: self.fakeDeviceInfoCollector)
    }
    
    func testContactFieldId_shouldReturnCorrectValue() throws {
        let result = self.config.contactFieldId
        
        XCTAssertEqual(result, testContactFieldId)
    }
    
    func testApplicationCode_shouldReturnCorrectValue() throws {
        let result = self.config.applicationCode
        
        XCTAssertEqual(result, testConfig.applicationCode)
    }
    
    func testMerchantId_shouldReturnCorrectValue() throws {
        let result = self.config.merchantId
        
        XCTAssertEqual(result, testConfig.merchantId)
    }
    
    func testHardwareId_shouldReturnCorrectValue() throws {
        let result = self.config.hardwareId
        
        XCTAssertEqual(result, testHwId)
    }
    
    func testLanguageCode_shouldReturnCorrectValue() throws {
        let result = self.config.languageCode
        
        XCTAssertEqual(result, testLanguageCode)
    }
    
    func testSdkVersion_shouldReturnCorrectValue() throws {
        let result = self.config.sdkVersion
        
        XCTAssertEqual(result, testSdkVersion)
    }
    
    func testPushSettings_shouldReturnCorrectValue() async throws {
        let result = await self.config.pushSettings()
        
        XCTAssertEqual(result, testPushSettings)
    }
    
    func testChangeApplicationCode_shouldDelegateToInstance() async throws {
        let otherAppCode = "otherAppCode"
        self.fakeConfigInternal.when(\.fnChangeApplicationCode).thenReturn(())
        
        try await self.config.changeApplicationCode(applicationCode: otherAppCode)
        
        let _ = try! self.fakeConfigInternal
            .verify(\.fnChangeApplicationCode)
            .wasCalled(Arg.eq(otherAppCode))
    }
    
    func testChangeApplicationCode_shouldNotDelegateToInstance_withInvalidInput() async throws {
        let otherAppCode = "nil"
        let expectedError = Errors.preconditionFailed(message: "Invalid value found: \(otherAppCode)!")
        self.fakeConfigInternal.when(\.fnChangeApplicationCode).thenReturn(())
        
        await assertThrows(expectedError: expectedError) {
            try await self.config.changeApplicationCode(applicationCode: otherAppCode)
        }
        
        let _ = try! self.fakeConfigInternal
            .verify(\.fnChangeApplicationCode)
            .times(times: .eq(0))
    }
    
    func testChangeMerchantId_shouldDelegateToInstance() async throws {
        let otherMerchantId = "otherMerchantId"
        self.fakeConfigInternal.when(\.fnChangeMerchantId).thenReturn(())
        
        try await self.config.changeMerchantId(merchantId: otherMerchantId)
        
        let _ = try! self.fakeConfigInternal
            .verify(\.fnChangeMerchantId)
            .wasCalled(Arg.eq(otherMerchantId))
    }
    
    func testChangeMerchantId_shouldNotDelegateToInstance_withInvalidInput() async throws {
        let otherMerchantId = "nil"
        let expectedError = Errors.preconditionFailed(message: "Invalid value found: \(otherMerchantId)!")
        self.fakeConfigInternal.when(\.fnChangeApplicationCode).thenReturn(())
        
        await assertThrows(expectedError: expectedError) {
            try await self.config.changeMerchantId(merchantId: otherMerchantId)
        }
        
        let _ = try! self.fakeConfigInternal
            .verify(\.fnChangeMerchantId)
            .times(times: .eq(0))
    }
}
