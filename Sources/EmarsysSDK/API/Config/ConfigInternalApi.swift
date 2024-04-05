//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol ConfigInternalApi {
    func changeApplicationCode(applicationCode: String) async throws
    func changeMerchantId(merchantId: String) async throws
}
