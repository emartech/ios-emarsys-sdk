//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension Dictionary {
    
    func toData() -> Data { // TODO: error handling
        return try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    
    static func + (left: Dictionary, right: Dictionary) -> Dictionary {
        return left.merging(right) { first, _ in
            first
        }
    }
    
}
