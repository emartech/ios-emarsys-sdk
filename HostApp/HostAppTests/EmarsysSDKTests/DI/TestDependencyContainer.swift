//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
import os
@testable import EmarsysSDK

@SdkActor
class TestDependencyContainer: DependencyContainer {
    private let logger: Logger = Logger(subsystem: Constants.Logger.subsystem, category: Constants.Logger.category)
    
    lazy var sdkConfig: SdkConfig = {
        return SdkConfig(version: "testVersion", cryptoPublicKey: "testCryptoPublicKey", remoteLogLevel: "testInfoLogLevel")
    }()
    
    lazy var defaultUrls: DefaultUrls = {
        return DefaultUrls(
            loggingUrl: "https://log-dealer.eservice.emarsys.net/v1/log",
            clientServiceBaseUrl: "https://base.me-client.eservice.emarsys.net",
            eventServiceBaseUrl: "https://base.mobile-events.eservice.emarsys.net",
            predictBaseUrl: "https://base.predict.eservice.emarsys.net",
            deepLinkBaseUrl: "https://base.deeplink.eservice.emarsys.net",
            inboxBaseUrl: "https://base.inbox.eservice.emarsys.net",
            remoteConfigBaseUrl: "https://base.remote-config.eservice.emarsys.net")
    }()
    
    lazy var sdkContext: SdkContext = {
        let emarsysConfig = EmarsysConfig(applicationCode: "EMS11-C3FD3")
        var context = SdkContext(sdkConfig: sdkConfig, defaultUrls: defaultUrls)
        context.config = emarsysConfig
        return context
    }()
    
    lazy var sessionContext: SessionContext = {
        return SessionContext(timestampProvider: timestampProvider, deviceInfoCollector: deviceInfoCollector)
    }()
    
    lazy var contactApi: ContactApi = {
        return FakeContactApi()
    }()
    
    //MARK: Clients
    lazy var pushClient: PushClient = {
        return FakePushClient()
    }()
    
    lazy var contactClient: ContactClient = {
        return FakeContactClient()
    }()
    
    lazy var eventClient: EventClient = {
        return FakeEventClient()
    }()
    
    lazy var emarsysClient: NetworkClient = {
        return FakeGenericNetworkClient()
    }()
    
    lazy var remoteConfigClient: any RemoteConfigClient = {
        return FakeRemoteConfigClient()
    }()
    
    lazy var genericNetworkClient: NetworkClient = {
        return FakeGenericNetworkClient()
    }()
    
    lazy var deviceClient: DeviceClient = {
        return FakeDeviceInfoClient()
    }()
    
    lazy var crypto: any Crypto = {
        return FakeCrypto()
    }()
    
    lazy var sdkLogger: SdkLogger = {
        return SdkLogger(defaultUrls: defaultUrls, logger: self.logger)
    }()
    
    lazy var secureStorage: SecureStorage = {
        return FakeSecureStorage()
    }()
    
    lazy var uuidProvider: any StringProvider = {
        return FakeUuidProvider()
    }()
    
    
    lazy var timestampProvider: any DateProvider = {
        return FakeTimestampProvider()
    }()
    
    lazy var randomProvider: any DoubleProvider = {
        return FakeRandomProvider()
    }()
    
    lazy var notificationCenterWrapper: NotificationCenterWrapper = {
        return FakeNotificationCenterWrapper()
    }()
    
    lazy var deviceInfoCollector: DeviceInfoCollector = {
        return FakeDeviceInfoCollector()
    }()
    
    
    //MARK: Setup
    lazy var setupOrganizer: SetupOrganizer = {
        return SetupOrganizer(stateMachine: StateMachine(states: []), sdkContext: sdkContext)
    }()
    
    lazy var remoteConfigHandler: RemoteConfigHandler = {
        return FakeRemoteConfigHandler()
    }()
}
