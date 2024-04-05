//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import mimic
@testable import EmarsysSDK


struct FakeConfigInternal: ConfigInstance, Mimic {
    let fnChangeApplicationCode = Fn<()>()
    let fnChangeMerchantId = Fn<()>()
    
    func changeApplicationCode(applicationCode: String) async throws {
        return try self.fnChangeApplicationCode.invoke(params: applicationCode)
    }
    
    func changeMerchantId(merchantId: String) async throws {
        return try self.fnChangeMerchantId.invoke(params: merchantId)
    }
}
