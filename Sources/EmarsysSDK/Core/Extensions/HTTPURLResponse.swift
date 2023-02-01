//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

extension HTTPURLResponse {
    
    func isOk() -> Bool {
        return 200 ... 299 ~= statusCode
    }
}
