//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct GathererConfig: ConfigInstance {
    
    func changeApplicationCode(applicationCode: String) async throws {
        
    }
    
    func changeMerchantId(merchantId: String) async throws {
        
    }
}

enum ConfigCall: Codable {
    case changeApplicationCode(applicationCode: String)
    case changeMerchantId(merchantId: String)
}