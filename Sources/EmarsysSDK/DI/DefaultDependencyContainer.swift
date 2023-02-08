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

    lazy var sdkContext: SdkContext = {
        return SdkContext(sdkConfig: sdkConfig, defaultUrls: defaultUrls)
    }()

    lazy var timestampProvider: any DateProvider = {
        return TimestampProvider()
    }()

    lazy var defaultUrls: DefaultUrls = {
        return try! loadPlist(name: defaultUrlsPlistName)
    }()

    lazy var sdkConfig: SdkConfig = {
        return try! loadPlist(name: sdkConfigPlistName)
    }()

    lazy var uuidProvider: any StringProvider = {
        return UUIDProvider()
    }()

    lazy var crypto: Crypto = {
        return Crypto(base64encodedPublicKey: sdkConfig.cryptoPublicKey, sdkLogger: sdkLogger)
    }()

    lazy var secureStorage: SecureStorage = {
        return DefaultSecureStorage()
    }()

    lazy var notificationCenterWrapper: NotificationCenterWrapper = {
        return DefaultNotificationCenterWrapper(notificationCenter: UNUserNotificationCenter.current())
    }()

    lazy var deviceInfoCollector: DeviceInfoCollector = {
        return DefaultDeviceInfoCollector(notificationCenterWrapper: notificationCenterWrapper, secureStorage: secureStorage, uuidProvider: uuidProvider, logger: sdkLogger)
    }()

    lazy var sessionContext: SessionContext = {
        return SessionContext(timestampProvider: timestampProvider)
    }()

    // MARK: Clients

    lazy var genericNetworkClient: NetworkClient = {
        let urlConfiguration = URLSessionConfiguration.default
        urlConfiguration.timeoutIntervalForRequest = 60.0
        urlConfiguration.httpCookieStorage = nil
        urlConfiguration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let urlSession = URLSession(configuration: urlConfiguration)
        let jsonDecoder = JSONDecoder()
        let jsonEncoder = JSONEncoder()
        return GenericNetworkClient(session: urlSession, decoder: jsonDecoder, encoder: jsonEncoder)
    }()

    lazy var contactClient: ContactClient = {
        DefaultContactClient(emarsysClient: genericNetworkClient,
                             sdkContext: sdkContext,
                             sessionContext: sessionContext,
                             sdkLogger: sdkLogger)
    }()
    
    lazy var sdkLogger: SdkLogger = SdkLogger()
    //
    //    lazy var remoteConfigClient: RemoteConfigClient = {
    //        return RemoteConfigClient(networkClient: standardNetworkClient, configContext: sdkContext, defaultValues: defaultValues, crypto: crypto)
    //    }()
    //
    lazy var emarsysClient: NetworkClient = {
        return EmarsysClient(networkClient: genericNetworkClient, deviceInfoCollector: deviceInfoCollector, defaultUrls: defaultUrls, sdkContext: sdkContext, sessionContext: sessionContext)
    }()
    //
    lazy var pushClient: PushClient = {
        return DefaultPushClient(emarsysClient: emarsysClient, sdkContext: sdkContext, sdkLogger: sdkLogger)
    }()
    //
    //    lazy var deeplinkClient: DeeplinkClient = {
    //        return DeeplinkClient(networkClient: networkClient, defaultValues: defaultValues, deviceInfoCollector: deviceInfoCollector)
    //    }()

    // MARK: Setup

    lazy var setupOrganizer: SetupOrganizer = {
        //  let fetchRemoteConfig = FetchRemoteConfigState(remoteConfigClient: remoteConfigClient)
        //  let registerClient = RegisterClientState(emarsysClient: emarsysClient)
        //   let registerPushToken = RegisterPushTokenState(pushClient: pushClient)
        let machine = StateMachine(states: [])
        return SetupOrganizer(stateMachine: machine, sdkContext: sdkContext)
    }()
    //
    //    // MARK: Api
    //
    lazy var contactApi: ContactApi = {
        let contactContext = ContactContext()

        let loggingContact = LoggingContact(logger: sdkLogger)
        let gathererContact = GathererContact(contactContext: contactContext)
        let contactInternal = ContactInternal(contactContext: contactContext, contactClient: contactClient)
        let predictContactInternal = PredictContactInternal(contactContext: contactContext, contactClient: contactClient)
        return Contact(loggingContact: loggingContact, gathererContact: gathererContact, contactInternal: contactInternal, predictContactInternal: predictContactInternal, sdkContext: sdkContext)
    }()
    //
    //    lazy var deeplinkApi: DeeplinkApi = {
    //        let loggingDeeplink = LoggingDeeplink()
    //        let deeplinkInternal = DeeplinkInternal(deeplinkClient: deeplinkClient)
    //        return Deeplink(loggingDeeplink: loggingDeeplink, deeplinkInternal: deeplinkInternal, sdkContext: sdkContext)
    //    }()
    //
}
