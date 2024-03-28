
import Foundation
import UserNotifications

extension UNNotificationSetting {
    
    func asString() -> String {
        var result = "notSupported"
        
        switch (self) {
        case UNNotificationSetting.enabled:
            result = "enabled"
        case UNNotificationSetting.disabled:
            result = "disabled"
        case UNNotificationSetting.notSupported:
            result = "notSupported"
        default: result = "notSupported"
        }
        
        return result
    }
}

extension UNShowPreviewsSetting {
    
    func asString() -> String {
        var result = "never"
        
        switch (self) {
        case UNShowPreviewsSetting.never:
            result = "never"
        case UNShowPreviewsSetting.whenAuthenticated:
            result = "whenAuthenticated"
        case UNShowPreviewsSetting.always:
            result = "always"
        default: result = "never"
        }
        
        return result
        
    }
}

extension UNAlertStyle {
    
    func asString() -> String {
        var alertStyle = "none"
        
        switch (self) {
        case UNAlertStyle.alert:
            alertStyle = "alert"
        case UNAlertStyle.banner:
            alertStyle = "banner"
        case UNAlertStyle.none:
            alertStyle = "none"
        default:alertStyle = "none"
        }
        
        return alertStyle
    }
}

extension UNAuthorizationStatus {
    
    func asString() -> String {
        return switch self {
        case .authorized: "authorized"
        case .notDetermined: "notDetermined"
        case .denied: "denied"
        case .provisional: "provisional"
#if os(iOS)
        case .ephemeral: "ephemeral"
#endif
        @unknown default: "notDetermined"
        }
    }
}
