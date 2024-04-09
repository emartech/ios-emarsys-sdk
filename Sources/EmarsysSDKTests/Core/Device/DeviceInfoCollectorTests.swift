import XCTest
import mimic
@testable import EmarsysSDK

@SdkActor
final class DeviceInfoCollectorTests: EmarsysTestCase {
    
    @Inject(\.uuidProvider)
    var fakeUuidProvider: FakeUuidProvider
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage
    
    @Inject(\.userNotificationCenterWrapper)
    var fakeUserNotificationCenterWrapper: FakeUserNotificationCenterWrapper
    
    @Inject(\.sdkLogger)
    var logger: SdkLogger
    
    @Inject(\.sdkConfig)
    var sdkConfig: SdkConfig
    
    @Inject(\.defaultUrls)
    var defaultUrls: DefaultUrls
    
    var deviceInfoCollector: DefaultDeviceInfoCollector!
    
    let testUuid = "testUuid"
    
    override func setUpWithError() throws {
        fakeUuidProvider
            .when(\.fnProvide)
            .thenReturn(self.testUuid)
        fakeUserNotificationCenterWrapper
            .when(\.fnNotificationSettings)
            .thenReturn(
                PushSettings(authorizationStatus: "", soundSetting: "", badgeSetting: "", alertSetting: "", notificationCenterSetting: "", lockScreenSetting: "", carPlaySetting: "", alertStyle: "", showPreviewsSetting: "", criticalAlertSetting: "", providesAppNotificationSettings: "", scheduledDeliverySetting: "", timeSensitiveSetting: "")
            )

        deviceInfoCollector = DefaultDeviceInfoCollector(notificationCenterWrapper: fakeUserNotificationCenterWrapper,
                                                         secureStorage: fakeSecureStorage,
                                                         uuidProvider: fakeUuidProvider,
                                                         sdkConfig: sdkConfig,
                                                         logger: logger)
    }
    
    func testHardwareId_shouldReturnStoredValue() async throws {
        let storedHardwareId: String = "stored hardware ID"
        
        fakeSecureStorage.when(\.fnGet).thenReturn(storedHardwareId)
        
        let result = await deviceInfoCollector.collect().hardwareId
        
        XCTAssertEqual(storedHardwareId, result)
        
    }
    
    func testHardwareId_shouldReturnGeneratedValue() async throws {
        let result = await deviceInfoCollector.collect().hardwareId
        
        XCTAssertEqual(result, testUuid)
    }
    
    func testHardwareId_shouldStoreGeneratedValue_inSecureStorage() async throws {
        let hardwareIdKey = "kHardwareIdKey"
        
        fakeSecureStorage
            .when(\.fnGet)
            .thenReturn(nil)
        
        fakeSecureStorage
            .when(\.fnPut)
            .thenReturn(())
        
        let result = await deviceInfoCollector.collect().hardwareId
        
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .wasCalled(Arg.eq(testUuid), Arg.eq(hardwareIdKey), Arg.nil)
            .times(times: .eq(1))
        
        XCTAssertEqual(result, testUuid)
    }
}
