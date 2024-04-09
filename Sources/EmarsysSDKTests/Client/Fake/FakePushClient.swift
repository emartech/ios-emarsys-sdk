//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK
import mimic

struct FakePushClient: PushClient, Mimic {
    
    let fnRegisterPushToken = Fn<()>()
    let fnRemovePushToken = Fn<()>()
    
    func registerPushToken(_ pushToken: String) async throws {
        return try fnRegisterPushToken.invoke(params: pushToken)
    }
    
    func removePushToken() async throws {
        return try fnRemovePushToken.invoke()
    }
    
}
