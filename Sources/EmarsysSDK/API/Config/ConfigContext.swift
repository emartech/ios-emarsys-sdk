//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class ConfigContext {
    let calls: PersistentList<ConfigCall>
    
    init(calls: PersistentList<ConfigCall>) {
        self.calls = calls
    }
}

enum ConfigCall: Codable, Equatable {
    case changeApplicationCode(applicationCode: String)
    case changeMerchantId(merchantId: String)
}
