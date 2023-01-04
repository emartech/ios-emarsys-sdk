//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
struct DependencyContainer: ResourceLoader {
    
    // MARK: Constants
    
    private let configPlistName = "Config"
    private let cryptoPublicKey = """
-----BEGIN PUBLIC KEY-----\n
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAELjWEUIBX9zlm1OI4gF1hMCBLzpaB\n
wgs9HlmSIBAqP4MDGy4ibOOV3FVDrnAY0Q34LZTbPBlp3gRNZJ19UoSy2Q==\n
-----END PUBLIC KEY-----
"""
    
    // MARK: Tools
    
    let sdkContext = SdkContext()
    
    lazy var defaultValues: DefaultValues = {
        return try! loadPlist(name: configPlistName)
    }()
    
    lazy var crypto: Crypto = {
        return Crypto(base64encodedPublicKey: cryptoPublicKey)
    }()
    
    lazy var deviceInfoCollector: DeviceInfoCollector = {
        return DeviceInfoCollector()
    }()
    
    // MARK: Clients
    
    lazy var networkClient: NetworkClient = {
        let urlConfiguration = URLSessionConfiguration.default
        urlConfiguration.timeoutIntervalForRequest = 60.0
        urlConfiguration.httpCookieStorage = nil
        let urlSession = URLSession(configuration: urlConfiguration)
        let jsonDecoder = JSONDecoder()
        let jsonEncoder = JSONEncoder()
        return DefaultNetworkClient(session: urlSession, decoder: jsonDecoder, encoder: jsonEncoder)
    }()
    
    lazy var contactClient: ContactClient = {
        return ContactClient(networkClient: networkClient, defaultValues: defaultValues, sdkContext: sdkContext)
    }()
    
    lazy var remoteConfigClient: RemoteConfigClient = {
        return RemoteConfigClient(networkClient: networkClient, configContext: sdkContext, defaultValues: defaultValues, crypto: crypto)
    }()
    
    lazy var emarsysClient: EmarsysClient = {
        return EmarsysClient(networkClient: networkClient, deviceInfoCollector: deviceInfoCollector, defaultValues: defaultValues, configContext: sdkContext)
    }()
    
    lazy var pushClient: PushClient = {
        return PushClient(networkClient: networkClient, defaultValues: defaultValues, configContext: sdkContext)
    }()
    
    lazy var deeplinkClient: DeeplinkClient = {
        return DeeplinkClient(networkClient: networkClient, defaultValues: defaultValues, deviceInfoCollector: deviceInfoCollector)
    }()
    
    // MARK: Setup
    
    lazy var setupOrganizer: SetupOrganizer = {
        let fetchRemoteConfig = FetchRemoteConfigState(remoteConfigClient: remoteConfigClient)
        let registerClient = RegisterClientState(emarsysClient: emarsysClient)
        let registerPushToken = RegisterPushTokenState(pushClient: pushClient)
        let machine = StateMachine(states: [fetchRemoteConfig, registerClient, registerPushToken], currentState: fetchRemoteConfig)
        return SetupOrganizer(stateMachine: machine, sdkContext: sdkContext)
    }()
    
    // MARK: Api
    
    lazy var contactApi: ContactApi = {
        let contactContext = ContactContext()
        
        let loggingContact = LoggingContact()
        let gathererContact = GathererContact(contactContext: contactContext)
        let contactInternal = ContactInternal(contactContext: contactContext, contactClient: self.contactClient)
        return Contact(loggingContact: loggingContact, gathererContact: gathererContact, contactInternal: contactInternal, sdkContext: sdkContext)
    }()
    
    lazy var deeplinkApi: DeeplinkApi = {
        let loggingDeeplink = LoggingDeeplink()
        let deeplinkInternal = DeeplinkInternal(deeplinkClient: deeplinkClient)
        return Deeplink(loggingDeeplink: loggingDeeplink, deeplinkInternal: deeplinkInternal, sdkContext: sdkContext)
    }()
    
}