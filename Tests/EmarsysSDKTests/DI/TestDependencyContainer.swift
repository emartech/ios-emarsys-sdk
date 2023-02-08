//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK

@SdkActor
class TestDependencyContainer: DependencyContainer {
    
    lazy var sdkContext: SdkContext = {
        let emarsysConfig = EmarsysConfig(applicationCode: "EMS11-C3FD3")
        var context = SdkContext(sdkConfig: sdkConfig, defaultUrls: defaultUrls)
        context.config = emarsysConfig
        return context
    }()
    
    lazy var timestampProvider: any DateProvider = {
        return FakeTimestampProvider()
    }()
    
    lazy var defaultUrls: DefaultUrls = {
        return DefaultUrls(clientServiceBaseUrl: "https://base.me-client.eservice.emarsys.net",
                           eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
                           predictBaseUrl: "https://base.predict.eservice.emarsys.net",
                           deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
                           inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
                           remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
    }()
    
    lazy var sdkConfig: SdkConfig = {
        return SdkConfig(version: "testVersion", cryptoPublicKey: "testCryptoPublicKey")
    }()
    
    lazy var uuidProvider: any StringProvider = {
        return FakeUuidProvider()
    }()
    
    lazy var crypto: Crypto = {
        return Crypto(base64encodedPublicKey: sdkConfig.cryptoPublicKey, sdkLogger: sdkLogger)
    }()
    
    lazy var secureStorage: SecureStorage = {
        return FakeSecureStorage()
    }()
    
    lazy var notificationCenterWrapper: NotificationCenterWrapper = {
        return FakeNotificationCenterWrapper()
    }()
    
    lazy var deviceInfoCollector: DeviceInfoCollector = {
        return FakeDeviceInfoCollector()
    }()
    
    lazy var sessionContext: SessionContext = {
        return SessionContext(timestampProvider: timestampProvider)
    }()
    
    lazy var genericNetworkClient: NetworkClient = {
        return FakeGenericNetworkClient()
    }()
    
    lazy var contactClient: ContactClient = {
        return FakeContactClient()
    }()
    
    lazy var sdkLogger: SdkLogger = {
        return SdkLogger()
    }()
    
    lazy var emarsysClient: NetworkClient = {
        return FakeGenericNetworkClient()
    }()
    
    lazy var pushClient: PushClient = {
        return DefaultPushClient(emarsysClient: emarsysClient, sdkContext: sdkContext, sdkLogger: sdkLogger)
    }()
    
    lazy var setupOrganizer: SetupOrganizer = {
        return SetupOrganizer(stateMachine: StateMachine(states: []), sdkContext: sdkContext)
    }()
    
    lazy var contactApi: ContactApi = {
        return FakeContactApi()
    }()

}
