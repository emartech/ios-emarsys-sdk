//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation


protocol Storable {

    func toData() -> Data
    
    static func fromData(_ data: Data) -> Self
    
}
