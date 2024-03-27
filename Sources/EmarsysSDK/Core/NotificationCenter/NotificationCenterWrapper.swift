//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct NotificationCenterWrapper: NotificationCenterWrapperApi {
    
    func post(_ topic: String, object: Any?) {
        NotificationCenter.default.post(name: Notification.emaName(topic), object: object)
    }
    
    func subscribe(_ topic: String) -> any AsyncSequence {
        return NotificationCenter.default.notifications(named: Notification.emaName(topic))
    }
    
}

extension Notification {
    
    fileprivate static func emaName(_ topic: String) -> Notification.Name {
        return Notification.Name("com.emarsys.sdk - \(topic)")
    }
    
}
