//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

extension HTTPURLResponse {
    
    func isOk() -> Bool {
        return 200 ... 299 ~= statusCode
    }
    
    func isRetriable() -> Bool {
        var result = false
        if !isOk() {
            if (statusCode == 408 || statusCode == 429) {
                result = true
            } else {
                result = !(400 <= statusCode && statusCode < 500)
            }
        }
        return result
    }
}
