//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct SdkConfig: Decodable {
    let version: String
    let cryptoPublicKey: String
    var remoteLogLevel: String
}
