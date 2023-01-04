//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension Dictionary {
    
    func toData() -> Data { // TODO: error handling
        return try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    
}
