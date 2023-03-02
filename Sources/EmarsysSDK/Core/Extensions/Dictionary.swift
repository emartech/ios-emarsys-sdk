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

extension Dictionary where Key == String, Value == Any {
    
    func lowerCaseKeys() -> Dictionary {
        return self.reduce([String: Any]()) { partialResult, item in
            var result = partialResult
            result[item.0.lowercased()] = item.1
            return result
        }
    }
}
