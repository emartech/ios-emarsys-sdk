//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class ConfigContext {
    var calls: any RangeReplaceableCollection<ConfigCall>
    
    init(calls: any RangeReplaceableCollection<ConfigCall>) {
        self.calls = calls
    }
}

enum ConfigCall: Codable, Equatable {
    case changeApplicationCode(applicationCode: String)
    case changeMerchantId(merchantId: String)
}
