//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension Dictionary {
    
    static func + (left: Dictionary, right: Dictionary) -> Dictionary {
        return left.merging(right) { first, _ in
            first
        }
    }
    
}
