//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation


extension [String] {
    
    func shouldNotContain(value: String) throws {
        if self.contains(value.lowercased()) {
            throw Errors.preconditionFailed(message: "Invalid value found: \(value)!")
        }
    }
}
