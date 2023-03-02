//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK


struct FakeDeviceInfoClient: DeviceClient, Faked {
    var faker = Faker()
    let registerClient = "registerClient"
    
    func registerClient() async throws {
        return try handleCall(\.registerClient)
    }
}
