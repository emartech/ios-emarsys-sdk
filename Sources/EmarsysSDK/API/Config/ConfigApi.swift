//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation


@SdkActor
protocol ConfigApi {
    var contactFieldId: Int? { get }
    var applicationCode: String? { get }
    var merchantId: String? { get }
    var hardwareId: String { get }
    var languageCode: String { get }
    var sdkVersion: String { get }

    func pushSettings() async -> PushSettings
    func changeApplicationCode(applicationCode: String) async throws
    func changeMerchantId(merchantId: String) async throws
}
