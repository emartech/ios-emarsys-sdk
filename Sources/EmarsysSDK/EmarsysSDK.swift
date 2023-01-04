public struct EmarsysSDK { //TODO: do we need static methods? probably.. but do we have convenient other ways?

    public static func initialize() async {
        let container = await DependencyContainer()
        DependencyInjection.setup(container)
    }
    
    public static func enableTracking(applicationCode: String, features: [Feature] = [.everything]) async {
        await DependencyInjection.container?.sdkContext.setConfig(config: Config(applicationCode: applicationCode))
        await DependencyInjection.container?.sdkContext.setSdkState(sdkState: .onHold)
        try? await DependencyInjection.container?.setupOrganizer.setup()
    }

    public static func linkContact(contactFieldId: Int, contactFieldValue: String) async {
        try? await DependencyInjection.container?.contactApi.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue)
    }
    
    public static func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async {
        try? await DependencyInjection.container?.contactApi.linkAuthenticatedContact(contactFieldId: contactFieldId, openIdToken: openIdToken)
    }
    
    public static func unlinkContact() async {
        try? await DependencyInjection.container?.contactApi.unlinkContact()
    }
    
    public static func trackEvent(name: String, payload: [String: String]) {
        
    }
    
    public static func trackDeeplink() async {
        
    }
    
}

public enum Feature {
    case everything
    case push
    case inapp
    case inbox
    case deeplink
    case predict(String)
}
