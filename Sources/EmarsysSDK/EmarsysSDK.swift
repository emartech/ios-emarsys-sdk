import Foundation
public struct EmarsysSDK { //TODO: TBD: do we need static methods? probably.. but do we have convenient other ways?
    // TODO: TBD: what if customers don't want to await a function call? how they can do it if we have only async functions?
    
    public static func initialize() async {
        let container = await DefaultDependencyContainer()
        DependencyInjection.setup(container)
        await DependencyInjection.container?.setup()
    }
    
    public static func enableTracking(_ config: EmarsysConfig) async throws {
        if try config.isValid() {
            await DependencyInjection.container?.sdkContext.setConfig(config: config)
            try? await DependencyInjection.container?.setupOrganizer.setup()
        }
    }
    //
    //    public static func linkContact(contactFieldId: Int, contactFieldValue: String) async {
    //        try? await DependencyInjection.container?.contactApi.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue)
    //    }
    //
    //    public static func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async {
    //        try? await DependencyInjection.container?.contactApi.linkAuthenticatedContact(contactFieldId: contactFieldId, openIdToken: openIdToken)
    //    }
    //
    //    public static func unlinkContact() async {
    //        try? await DependencyInjection.container?.contactApi.unlinkContact()
    //    }
    //
    //    public static func trackEvent(name: String, payload: [String: String]) {
    //
    //    }
    //
    //    public static func trackDeeplink(userActivity: NSUserActivity) async throws -> Bool {
    //        return try! await DependencyInjection.container!.deeplinkApi.trackDeeplink(userActivity: userActivity)
    //    }
    //
}
