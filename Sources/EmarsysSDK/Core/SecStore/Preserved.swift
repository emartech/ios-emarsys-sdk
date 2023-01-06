//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@propertyWrapper
struct Preserved {
    
    let key: String
    var accessGroup: String? = nil
    
    var wrappedValue: Data? {
        get {
            return try? SecStore.instance.get(key: key, accessGroup: accessGroup)
        }
        set {
            try? SecStore.instance.put(data: newValue, key: key, accessGroup: accessGroup)
        }
    }
    
}
