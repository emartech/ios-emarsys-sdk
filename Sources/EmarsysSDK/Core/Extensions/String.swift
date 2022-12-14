//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, bundle: Bundle.module, comment: "")
    }
    
    func localized(with args: String...) -> String {
        return String(format: self.localized(), arguments: args)
    }
}
