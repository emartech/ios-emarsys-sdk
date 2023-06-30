//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import XCTest
@testable import EmarsysSDK
import mimic

@SdkActor
final class DefaultRemoteConfigHandlerTests: EmarsysTestCase {
    
    @Inject(\.deviceInfoCollector)
    var fakeDeviceInfoCollector: FakeDeviceInfoCollector
    
    @Inject(\.remoteConfigClient)
    var fakeRemoteConfigClient: FakeRemoteConfigClient
    
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.sdkLogger)
    var sdkLogger: SdkLogger
    
    @Inject(\.randomProvider)
    var fakeRandomProvider: FakeRandomProvider
    
    var testDeviceInfo: DeviceInfo!
    var testRemoteConfigResponse: RemoteConfigResponse!
    
    let testHardwareId = "testHardwareId"
    let testLogLevel = "testLogLevel"
    
    var remoteConfigHandler: DefaultRemoteConfigHandler!
    
    override func setUpWithError() throws {
        testRemoteConfigResponse = RemoteConfigResponse(serviceUrls: ServiceUrls(eventService: "newEventService", clientService: "newClientService", predictService: "newPredictService", deepLinkService: "newDeepLinkService", inboxService: "newInboxService"), logLevel: testLogLevel, luckyLogger: LuckyLogger(logLevel: "ERROR", threshold: 0.0), features: RemoteConfigFeatures(mobileEngage: false, predict: true))
        
        testDeviceInfo = DeviceInfo(platform: "iOS", applicationVersion: "", deviceModel: "", osVersion: "", sdkVersion: "", language: "", timezone: "", pushSettings: PushSettings(authorizationStatus: "", soundSetting: "", badgeSetting: "", alertSetting: "", notificationCenterSetting: "", lockScreenSetting: "", carPlaySetting: "", alertStyle: "", showPreviewsSetting: "", criticalAlertSetting: "", providesAppNotificationSettings: "", scheduledDeliverySetting: "", timeSensitiveSetting: ""), hardwareId: testHardwareId)
        
        
        fakeRemoteConfigClient
            .when(\.fnFetchRemoteConfig)
            .thenReturn(testRemoteConfigResponse)
        fakeDeviceInfoCollector
            .when(\.fnCollect)
            .thenReturn(testDeviceInfo)
        fakeRandomProvider
            .when(\.fnProvide)
            .thenReturn(0.0)
        
        remoteConfigHandler = DefaultRemoteConfigHandler(
            deviceInfoCollector: fakeDeviceInfoCollector,
            remoteConfigClient: fakeRemoteConfigClient,
            sdkContext: sdkContext,
            sdkLogger: sdkLogger,
            randomProvider: fakeRandomProvider)
    }
    
    func testHandle_shouldDoNothing_whenConfig_isNil() async throws {
        fakeRemoteConfigClient.when(\.fnFetchRemoteConfig).thenReturn(nil)
        
        try! await remoteConfigHandler.handle()
        
        _ = try fakeDeviceInfoCollector
            .verify(\.fnCollect)
            .times(times: .zero)
    }
    
    
    func testHandle_shouldFetchRemoteConfig() async throws {
        try! await remoteConfigHandler.handle()
        
        _ = try fakeRemoteConfigClient
            .verify(\.fnFetchRemoteConfig)
            .times(times: .eq(1))
    }
    
    func testHandle_shouldAcquireHardwareId() async throws {
        try! await remoteConfigHandler.handle()
        
        _ = try fakeDeviceInfoCollector
            .verify(\.fnCollect)
            .times(times: .eq(1))
    }
    
    func testHandle_shouldOverrideConfig_whenServiceUrls_arePresent() async throws {
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.defaultUrls, DefaultUrls(loggingUrl: "https://log-dealer.eservice.emarsys.net/v1/log", clientServiceBaseUrl: "newClientService", eventServiceBaseUrl: "newEventService", predictBaseUrl: "newPredictService", deepLinkBaseUrl: "newDeepLinkService", inboxBaseUrl: "newInboxService", remoteConfigBaseUrl: sdkContext.defaultUrls.remoteConfigBaseUrl))
    }
    
    func testHandle_shouldOverrideConfig_whenLogLevel_isPresent() async throws {
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.sdkConfig.remoteLogLevel, testLogLevel)
    }
    
    func testHandle_shouldOverrideConfig_whenLuckyLogger_isPresent() async throws {
        let remoteConfig = RemoteConfigResponse(serviceUrls: ServiceUrls(eventService: "newEventService", clientService: "newClientService", predictService: "newPredictService", deepLinkService: "newDeepLinkService", inboxService: "newInboxService"), logLevel: testLogLevel, luckyLogger: LuckyLogger(logLevel: "ERROR", threshold: 1.0), features: RemoteConfigFeatures(mobileEngage: false, predict: true))
        fakeRemoteConfigClient
            .when(\.fnFetchRemoteConfig)
            .thenReturn(remoteConfig)

        fakeRandomProvider
            .when(\.fnProvide)
            .thenReturn(0.5)
        
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.sdkConfig.remoteLogLevel, "ERROR")
    }
    
    func testHandle_shouldDisableMobileEngage_whenMobileEngageFeature_isEnabled() async throws {
        let remoteConfig = RemoteConfigResponse(serviceUrls: ServiceUrls(eventService: "newEventService", clientService: "newClientService", predictService: "newPredictService", deepLinkService: "newDeepLinkService", inboxService: "newInboxService"), logLevel: testLogLevel, luckyLogger: LuckyLogger(logLevel: "ERROR", threshold: 1.0), features: RemoteConfigFeatures(mobileEngage: false, predict: true))
        
        fakeRemoteConfigClient
            .when(\.fnFetchRemoteConfig)
            .thenReturn(remoteConfig)
        
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.features.count, 1)
        XCTAssertTrue(sdkContext.features.contains(.predict))
    }
    
    func testHandle_shouldEnableBoth_MobileEngage_Predict() async throws {
        let remoteConfig = RemoteConfigResponse(serviceUrls: ServiceUrls(eventService: "newEventService", clientService: "newClientService", predictService: "newPredictService", deepLinkService: "newDeepLinkService", inboxService: "newInboxService"), logLevel: testLogLevel, luckyLogger: LuckyLogger(logLevel: "ERROR", threshold: 1.0), features: RemoteConfigFeatures(mobileEngage: true, predict: true))
        
        fakeRemoteConfigClient
            .when(\.fnFetchRemoteConfig)
            .thenReturn(remoteConfig)
        
        sdkContext.features = [.predict]
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.features.count, 2)
        XCTAssertTrue(sdkContext.features.contains(.predict))
        XCTAssertTrue(sdkContext.features.contains(.mobileEngage))
    }
    
    func testHandle_shouldIgnoreFeatures_whenOverrideFeatures_areNil() async throws {
        let remoteConfig = RemoteConfigResponse(serviceUrls: ServiceUrls(eventService: "newEventService", clientService: "newClientService", predictService: "newPredictService", deepLinkService: "newDeepLinkService", inboxService: "newInboxService"), logLevel: testLogLevel, luckyLogger: LuckyLogger(logLevel: "ERROR", threshold: 1.0), features: RemoteConfigFeatures(mobileEngage: nil, predict: nil))
        
        fakeRemoteConfigClient
            .when(\.fnFetchRemoteConfig)
            .thenReturn(remoteConfig)
        
        sdkContext.features = [.mobileEngage, .predict]
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.features.count, 2)
        XCTAssertTrue(sdkContext.features.contains(.predict))
        XCTAssertTrue(sdkContext.features.contains(.mobileEngage))
    }
    
    func testHandle_shouldDisablePredict_whenPredictFeature_isDisabled() async throws {
        let remoteConfig = RemoteConfigResponse(serviceUrls: ServiceUrls(eventService: "newEventService", clientService: "newClientService", predictService: "newPredictService", deepLinkService: "newDeepLinkService", inboxService: "newInboxService"), logLevel: testLogLevel, luckyLogger: LuckyLogger(logLevel: "ERROR", threshold: 1.0), features: RemoteConfigFeatures(mobileEngage: true, predict: false))
        
        fakeRemoteConfigClient
            .when(\.fnFetchRemoteConfig)
            .thenReturn(remoteConfig)
        
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.features.count, 1)
        XCTAssertTrue(sdkContext.features.contains(.mobileEngage))
    }
    
    func testHandle_shouldOverride_basedOnHardwareId() async throws {
        let remoteConfig : RemoteConfigResponse = RemoteConfigResponse(serviceUrls: ServiceUrls(eventService: "newEventService", clientService: "newClientService", predictService: "newPredictService", deepLinkService: "newDeepLinkService", inboxService: "newInboxService"), logLevel: testLogLevel, luckyLogger: LuckyLogger(logLevel: "ERROR", threshold: 1.0), features: RemoteConfigFeatures(mobileEngage: true, predict: true), overrides: [testHardwareId : RemoteConfig(serviceUrls: ServiceUrls(eventService: "HARDWARE_ID_OVERRIDE"), logLevel: "HARDWARE_ID_OVERRIDE", features: RemoteConfigFeatures(mobileEngage: true, predict: false))])
        
        fakeRemoteConfigClient
            .when(\.fnFetchRemoteConfig)
            .thenReturn(remoteConfig)
        
        sdkContext.features = [.predict]
        try! await remoteConfigHandler.handle()
        
        XCTAssertEqual(sdkContext.features.count, 1)
        XCTAssertTrue(sdkContext.features.contains(.mobileEngage))
        XCTAssertEqual(sdkContext.defaultUrls, DefaultUrls(loggingUrl: "https://log-dealer.eservice.emarsys.net/v1/log", clientServiceBaseUrl: "newClientService", eventServiceBaseUrl: "HARDWARE_ID_OVERRIDE", predictBaseUrl: "newPredictService", deepLinkBaseUrl: "newDeepLinkService", inboxBaseUrl: "newInboxService", remoteConfigBaseUrl: sdkContext.defaultUrls.remoteConfigBaseUrl))
        XCTAssertEqual(sdkContext.sdkConfig.remoteLogLevel, "HARDWARE_ID_OVERRIDE")
        
    }
}
