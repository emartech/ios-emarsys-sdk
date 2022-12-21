public struct EmarsysSDK {
    

    public init() {

    }
    
    public static func initialize() {
        
    }
    
    public static func enableTracking(applicationCode: String, features: [Feature] = [.everything]) {
        
    }
    
    public static func trackEvent(name: String, payload: [String: String]) {
        
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
