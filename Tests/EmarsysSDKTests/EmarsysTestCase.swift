//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

@SdkActor
open class EmarsysTestCase: XCTestCase {

    var fakeNetworkClient: FakeGenericNetworkClient!
    var sessionContext: SessionContext!
    var fakeTimestampProvider: FakeTimestampProvider!
    var defaultUrls: DefaultUrls!
    var deviceInfo: DeviceInfo!

    var sdkConfig: SdkConfig!
    var emarsysConfig: EmarsysConfig!
    var sdkContext: SdkContext!
    var sdkLogger: SdkLogger!

    open override func setUpWithError() throws {
        fakeNetworkClient = FakeGenericNetworkClient()
        fakeTimestampProvider = FakeTimestampProvider()

        defaultUrls = DefaultUrls(clientServiceBaseUrl: "https://base.me-client.eservice.emarsys.net",
                                  eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                                  predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                                  deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                                  inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                                  remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
        sdkConfig = SdkConfig(version: "testVersion", cryptoPublicKey: "testCryptoPublicKey")
        emarsysConfig = EmarsysConfig(applicationCode: "EMS11-C3FD3")
        sessionContext = SessionContext(timestampProvider: fakeTimestampProvider)
        sdkContext = SdkContext(sdkConfig: sdkConfig, defaultUrls: defaultUrls)
        sdkContext.config = emarsysConfig
        deviceInfo = DeviceInfo(platform: "iOS",
                                applicationVersion: "testVersion",
                                deviceModel: "iPhone14Pro",
                                osVersion: "16.1",
                                sdkVersion: "4.0.0",
                                language: "english",
                                timezone: "testZone",
                                pushSettings: PushSettings(authorizationStatus: "testAuthStatus",
                                                           soundSetting: "testSoundSetting",
                                                           badgeSetting: "testBadgeSetting",
                                                           alertSetting: "testAlertSetting",
                                                           notificationCenterSetting: "testNotificationSetting",
                                                           lockScreenSetting: "testLockScreenSetting",
                                                           carPlaySetting: "testCarPlaySetting",
                                                           alertStyle: "testAlertStyle",
                                                           showPreviewsSetting: "showPreviewSetting",
                                                           criticalAlertSetting: "testCriticalSetting",
                                                           providesAppNotificationSettings: "testProvidesAppNotificationSettings",
                                                           scheduledDeliverySetting: "testScheduledDeliverySetting",
                                                           timeSensitiveSetting: "testTimeSensitiveSetting"))
        sdkLogger = SdkLogger()
    }

    open override func tearDownWithError() throws {
        fakeNetworkClient.tearDown()
        fakeTimestampProvider.tearDown()
    }
    
}
