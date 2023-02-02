//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

extension Data: Storable {
    
    func toData() -> Data {
        self
    }
    
    static func fromData(_ data: Data) -> Data {
        data
    }
}

extension String: Storable {
    
    func toData() -> Data {
        Data(self.utf8)
    }
    
    static func fromData(_ data: Data) -> String {
        return String(data: data, encoding: .utf8)!
    }
}

extension Int: Storable {

    func toData() -> Data {
        let dictionary = ["value": self]
        return dictionary.toData()
    }
    
    static func fromData(_ data: Data) -> Int {
        let dictionary = data.toDict()
        return dictionary["value"] as! Int
    }
}

extension Bool: Storable {
    
    func toData() -> Data {
        let dictionary = ["value": self]
        return dictionary.toData()
        
    }
    
    static func fromData(_ data: Data) -> Bool {
        let dictionary = data.toDict()
        return dictionary["value"] as! Bool
    }
}

extension Dictionary: Storable {
    
    func toData() -> Data {
        return try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) // TODO: handle error
    }
    
    static func fromData<Key, Value>(_ data: Data) -> Dictionary<Key, Value> {
        return try! JSONSerialization.jsonObject(with: data) as! [Key : Value]
    }
}
