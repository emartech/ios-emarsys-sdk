//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK
import mimic


struct FakeDeviceInfoClient: DeviceClient, Mimic {

    let fnRegisterClient = Fn<()>()
    
    func registerClient() async throws {
        return try fnRegisterClient.invoke()
    }
}
