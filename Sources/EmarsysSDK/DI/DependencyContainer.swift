//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
protocol DependencyContainer {
    
    var sdkConfig: SdkConfig { mutating get set }
    var defaultUrls: DefaultUrls { mutating get set }
    var sdkContext: SdkContext { mutating get set }
    var sessionContext: SessionContext { mutating get set }

    var contactApi: ContactApi { mutating get set }
    var eventApi: EventApi { mutating get set }

    var pushClient: PushClient { mutating get set }
    var contactClient: ContactClient { mutating get set }
    var emarsysClient: NetworkClient { mutating get set }
    var eventClient: EventClient { mutating get set }
    var remoteConfigClient: RemoteConfigClient { mutating get set }
    var genericNetworkClient: NetworkClient { mutating get set }
    var deviceClient: DeviceClient { mutating get set }

    var crypto: any Crypto { mutating get set }
    var sdkLogger: SdkLogger { mutating get set }
    var secureStorage: SecureStorage { mutating get set }
    var uuidProvider: any StringProvider { mutating get set }
    var timestampProvider: any DateProvider { mutating get set }
    var userNotificationCenterWrapper: UserNotificationCenterWrapper { mutating get set }
    var notificationCenterWrapper: NotificationCenterWrapperApi { mutating get set }
    var deviceInfoCollector: DeviceInfoCollector { mutating get set }

    var setupOrganizer: SetupOrganizer { mutating get set }
    var remoteConfigHandler: RemoteConfigHandler { mutating get set }
}
