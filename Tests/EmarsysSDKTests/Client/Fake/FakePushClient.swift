//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK

struct FakePushClient: PushClient, Faked {
    
    let faker = Faker()
    
    let registerPushToken = "register"
    let removePushToken = "remove"
    
    func registerPushToken(_ pushToken: String) async throws {
        return try handleCall(\.registerPushToken, params: pushToken)
    }
    
    func removePushToken() async throws {
        return try handleCall(\.removePushToken)
    }
    
}
