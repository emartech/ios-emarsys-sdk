//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

extension Data: Storable {
    
    func toData() -> Data {
        self
    }
    
    func fromData(data: Data) -> Data {
        self
    }
}

extension String: Storable {
    
    func toData() -> Data {
        Data(self.utf8)
    }
    
    func fromData(data: Data) -> String {
        return String(data: data, encoding: .utf8)!
    }
}

extension Int: Storable {

    func toData() -> Data {
        let dictionary = ["value": self]
        return dictionary.toData()
    }
    
    func fromData(data: Data) -> Int {
        let dictionary = data.toDict()
        return dictionary["value"] as! Int
    }
}

extension Bool: Storable {
    
    func toData() -> Data {
//        var _self = self
//        let data = NSData(bytes: &_self, length: MemoryLayout.size(ofValue: self))
//        return Data(referencing: data)
        let dictionary = ["value": self]
        return dictionary.toData()
        
    }
    
    func fromData(data: Data) -> Bool {
//        var value = false
//        NSData(data: data).getBytes(&value, length: MemoryLayout<Bool>.size)
//        return value
        let dictionary = data.toDict()
        return dictionary["value"] as! Bool
    }
}
