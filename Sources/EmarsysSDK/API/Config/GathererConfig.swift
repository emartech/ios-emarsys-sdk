//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct GathererConfig: ConfigInstance {
    
    let configContext: ConfigContext
    
    func changeApplicationCode(applicationCode: String) async throws {
        configContext.calls.append(.changeApplicationCode(applicationCode: applicationCode))
    }
    
    func changeMerchantId(merchantId: String) async throws {
        configContext.calls.append(.changeMerchantId(merchantId: merchantId))
    }
}
