//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UserNotifications
import os

@SdkActor
struct DefaultDependencyContainer: DependencyContainer, ResourceLoader {
    // MARK: Constants
    
    private let defaultUrlsPlistName = "DefaultUrls"
    private let sdkConfigPlistName = "SdkConfig"
    
    // MARK: Tools
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    private let logger = Logger(subsystem: Constants.Logger.subsystem, category: Constants.Logger.category)
    
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
        return SessionContext(timestampProvider: timestampProvider, deviceInfoCollector: deviceInfoCollector)
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
    
    lazy var eventApi: EventApi = {
        let eventContext = EventContext()
        let loggingEvent = LoggingEvent(logger: sdkLogger)
        let gathererEvent = GathererEvent(eventContext: eventContext)
        let eventInternal = EventInternal(eventContext: eventContext,
                                          eventClient: eventClient,
                                          timestampProvider: timestampProvider)
        return Event(loggingInstance: loggingEvent,
                     gathererInstance: gathererEvent,
                     internalInstance: eventInternal,
                     sdkContext: sdkContext)
    }()
    
    // MARK: Clients
    
    lazy var pushClient: PushClient = {
        return DefaultPushClient(emarsysClient: emarsysClient, sdkContext: sdkContext, sdkLogger: sdkLogger)
    }()
    
    lazy var contactClient: ContactClient = {
        return DefaultContactClient(emarsysClient: emarsysClient,
                                    sdkContext: sdkContext,
                                    sessionContext: sessionContext,
                                    sdkLogger: sdkLogger)
    }()
    
    lazy var emarsysClient: NetworkClient = {
        return EmarsysClient(networkClient: genericNetworkClient,
                             deviceInfoCollector: deviceInfoCollector,
                             defaultUrls: defaultUrls,
                             sdkContext: sdkContext,
                             sessionContext: sessionContext)
    }()
    
    lazy var eventClient: EventClient = {
        return DefaultEventClient(networkClient: emarsysClient,
                                  sdkContext: sdkContext,
                                  sessionContext: sessionContext,
                                  timestampProvider: timestampProvider)
    }()
    
    lazy var remoteConfigClient: RemoteConfigClient = {
        return DefaultRemoteConfigClient(networkClient: genericNetworkClient,
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
    
    lazy var deviceClient: DeviceClient = {
        return DefaultDeviceClient(emarsysClient: emarsysClient, sdkContext: sdkContext, deviceInfoCollector: deviceInfoCollector)
    }()
    
    lazy var crypto: any Crypto = {
        return DefaultCrypto(base64encodedPublicKey: sdkConfig.cryptoPublicKey, sdkLogger: sdkLogger)
    }()
    
    lazy var sdkLogger: SdkLogger = {
        SdkLogger(defaultUrls: self.defaultUrls, logger: self.logger)
    }()
    
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
        return DefaultDeviceInfoCollector(notificationCenterWrapper: notificationCenterWrapper,
                                          secureStorage: secureStorage,
                                          uuidProvider: uuidProvider,
                                          sdkConfig: sdkConfig,
                                          logger: sdkLogger)
    }()
    
    // MARK: Setup
    lazy var setupOrganizer: SetupOrganizer = {
        let applyRemoteConfigState = ApplyRemoteConfigState(remoteConfigHandler: remoteConfigHandler)
        let registerClientState = RegisterClientState(deviceClient: deviceClient)
        let linkContactState = LinkContactState(contactClient: contactClient, secureStorage: secureStorage)
        let registerPushTokenState = RegisterPushTokenState(pushClient: pushClient, secureStorage: secureStorage)
        let machine = StateMachine(states: [applyRemoteConfigState, registerClientState, registerPushTokenState, linkContactState])
        return SetupOrganizer(stateMachine: machine, sdkContext: sdkContext)
    }()
    
    lazy var remoteConfigHandler: RemoteConfigHandler = {
        return DefaultRemoteConfigHandler(deviceInfoCollector: deviceInfoCollector,
                                          remoteConfigClient: remoteConfigClient,
                                          sdkContext: sdkContext,
                                          sdkLogger: sdkLogger,
                                          randomProvider: RandomProvider(in: 0.0...1.0))
    }()
}
