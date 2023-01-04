//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension Data {
    
    func toDict() -> [String: Any] { // TODO: error handling
        return try! JSONSerialization.jsonObject(with: self) as! [String : Any]
    }
    
    func toString() -> String {  // TODO: error handling
        return String(data: self, encoding: .utf8)!
    }
    
}
