//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UserNotifications

@SdkActor
struct DefaultDependencyContainer: DependencyContainer, ResourceLoader {
    // MARK: Constants

    private let defaultUrlsPlistName = "DefaultUrls"
    private let sdkConfigPlistName = "SdkConfig"

    // MARK: Tools
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    
    lazy var sdkConfig: SdkConfig = {
        return try! loadPlist(name: sdkConfigPlistName)
    }()
    
    lazy var defaultUrls: DefaultUrls = {
        return try! loadPlist(name: defaultUrlsPlistName)
    }()

    lazy var sdkContext: SdkContext = {
        return SdkContext(sdkConfig: sdkConfig, defaultUrls: defaultUrls)
    }()
    
    lazy var sessionContext: SessionContext = {
        return SessionContext(timestampProvider: timestampProvider)
    }()
    
    // MARK: Api
    
    lazy var contactApi: ContactApi = {
        let contactContext = ContactContext()

        let loggingContact = LoggingContact(logger: sdkLogger)
        let gathererContact = GathererContact(contactContext: contactContext)
        let contactInternal = ContactInternal(contactContext: contactContext, contactClient: contactClient)
        let predictContactInternal = PredictContactInternal(contactContext: contactContext, contactClient: contactClient)
        return Contact(loggingContact: loggingContact, gathererContact: gathererContact, contactInternal: contactInternal, predictContactInternal: predictContactInternal, sdkContext: sdkContext)
    }()
    
    // MARK: Clients

    lazy var pushClient: PushClient = {
        return DefaultPushClient(emarsysClient: emarsysClient, sdkContext: sdkContext, sdkLogger: sdkLogger)
    }()
    
    lazy var contactClient: ContactClient = {
        DefaultContactClient(emarsysClient: genericNetworkClient,
                             sdkContext: sdkContext,
                             sessionContext: sessionContext,
                             sdkLogger: sdkLogger)
    }()
    
    lazy var emarsysClient: NetworkClient = {
        return EmarsysClient(networkClient: genericNetworkClient, deviceInfoCollector: deviceInfoCollector, defaultUrls: defaultUrls, sdkContext: sdkContext, sessionContext: sessionContext)
    }()
    
    lazy var remoteConfigClient: RemoteConfigClient = {
        DefaultRemoteConfigClient(networkClient: genericNetworkClient,
                                  sdkContext: sdkContext,
                                  crypto: crypto,
                                  jsonDecoder: jsonDecoder,
                                  logger: sdkLogger)
    }()
    
    lazy var genericNetworkClient: NetworkClient = {
        let urlConfiguration = URLSessionConfiguration.default
        urlConfiguration.timeoutIntervalForRequest = 60.0
        urlConfiguration.httpCookieStorage = nil
        urlConfiguration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let urlSession = URLSession(configuration: urlConfiguration)
        return GenericNetworkClient(session: urlSession, decoder: jsonDecoder, encoder: jsonEncoder)
    }()
    
    lazy var crypto: any Crypto = {
        return DefaultCrypto(base64encodedPublicKey: sdkConfig.cryptoPublicKey, sdkLogger: sdkLogger)
    }()
    
    lazy var sdkLogger: SdkLogger = SdkLogger()
    
    lazy var secureStorage: SecureStorage = {
        return DefaultSecureStorage()
    }()
    
    lazy var uuidProvider: any StringProvider = {
        return UUIDProvider()
    }()
    
    lazy var timestampProvider: any DateProvider = {
        return TimestampProvider()
    }()

    lazy var notificationCenterWrapper: NotificationCenterWrapper = {
        return DefaultNotificationCenterWrapper(notificationCenter: UNUserNotificationCenter.current())
    }()

    lazy var deviceInfoCollector: DeviceInfoCollector = {
        return DefaultDeviceInfoCollector(notificationCenterWrapper: notificationCenterWrapper, secureStorage: secureStorage, uuidProvider: uuidProvider, logger: sdkLogger)
    }()

    // MARK: Setup
    lazy var setupOrganizer: SetupOrganizer = {
        //  let fetchRemoteConfig = FetchRemoteConfigState(remoteConfigClient: remoteConfigClient)
        //  let registerClient = RegisterClientState(emarsysClient: emarsysClient)
        //   let registerPushToken = RegisterPushTokenState(pushClient: pushClient)
        let machine = StateMachine(states: [])
        return SetupOrganizer(stateMachine: machine, sdkContext: sdkContext)
    }()
}