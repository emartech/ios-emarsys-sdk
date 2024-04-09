//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation
@testable import EmarsysSDK
import mimic

@SdkActor
struct FakeNotificationCenterWrapper: NotificationCenterWrapperApi, Mimic {

    let p: Fn<Void> = Fn()
    let s: Fn<any AsyncSequence> = Fn()

    nonisolated func post(_ topic: String, object: Any?) {
        return try! p.invoke(params: topic, object as Any)
    }
    
    nonisolated func subscribe(_ topic: String) -> any AsyncSequence {
        return try! s.invoke(params: topic)
    }
    
}
