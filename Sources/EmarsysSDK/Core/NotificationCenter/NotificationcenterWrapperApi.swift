//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

protocol NotificationCenterWrapperApi {
    
    func post(_ topic: String, object: Any?)
    
    func subscribe(_ topic: String) -> any AsyncSequence
    
}
