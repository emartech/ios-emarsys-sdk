//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol PushClient {
    func registerPushToken(_ pushToken: String) async throws
    func removePushToken() async throws
}
