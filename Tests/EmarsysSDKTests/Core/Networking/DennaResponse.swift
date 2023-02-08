//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct DennaResponse<Body: Decodable>: Decodable {
    let method: String
    let headers: [String: String]
    let body: Body
}
