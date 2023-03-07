//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct GenericAction: Codable {
    let type: String
    let url: String?
    let name: String?
    let payload: [String: String]?
}