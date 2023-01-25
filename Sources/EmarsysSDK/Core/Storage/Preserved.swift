//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@propertyWrapper
struct Preserved {
    
    let key: String
    var accessGroup: String? = nil
    var wrappedValue: Data?
    
//    var wrappedValue: Data? {
//        get {
//            return try? SecureStorage.instance.get(key: key, accessGroup: accessGroup) as? Data
//        }
//        set {
//            try? SecureStorage.instance.put(data: newValue as? Data, key: key, accessGroup: accessGroup)
//        }
//    }
    
}
