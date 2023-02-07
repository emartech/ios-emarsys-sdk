
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
        
        var result = "notDetermined"
        
        if (self == UNAuthorizationStatus.authorized) {
            result = "authorized"
        } else if (self == UNAuthorizationStatus.denied) {
            result = "denied"
        } else if (self == UNAuthorizationStatus.notDetermined) {
            result = "notDetermined"
        } else if (self == UNAuthorizationStatus.ephemeral) {
            result = "ephemeral"
        } else if #available(iOS 12.0, *) {
            if (self == UNAuthorizationStatus.provisional) {
                result = "provisional"
            }
        }
        return result
    }
}
