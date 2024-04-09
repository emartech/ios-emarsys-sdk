//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension Dictionary where Key == String, Value: Equatable {
    
    func subDict(dict: [String: any Equatable]) -> Bool {
        let count = dict.count
        let resultDict = self.filter { key, value in
            return dict[key] as? Value == value
        }
        return count == resultDict.count && count != 0
    }

}

extension Dictionary {
    
    func equals(dict: [String: Any]) -> Bool {
        return NSDictionary(dictionary: self).isEqual(to: dict)
    }
    
}
